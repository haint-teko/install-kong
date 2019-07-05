local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"

local kong = kong
local DecisionMakerHandler = BasePlugin:extend()
local HTTP_500 = 500

DecisionMakerHandler.VERSION = "1.0.0"
DecisionMakerHandler.PRIORITY = 1010
local pl_pretty = require "pl.pretty"


function DecisionMakerHandler:new()
  DecisionMakerHandler.super.init_worker(self, "decision-maker")
end


local function make_decision(conf)
  local client = http.new()
  local request_method = kong.request.get_method()
  local request_path = kong.request.get_path_with_query()
  local request_body = kong.request.get_raw_body()
  local request_headers = kong.request.get_headers()
  local service = kong.router.get_service()
  request_headers["X-Upstream-Host"] = service.host .. ":" .. service.port

  local connected = false
  local decision_maker_path = "/decisions"
  for decision_maker in kong.db.decision_makers:each() do
    client:set_timeout(500)
    local ok, err = client:connect(decision_maker.host, decision_maker.port)
    if not ok then
      local domain = decision_maker.host .. ":" .. decision_maker.port
      kong.log.err("Could not connect to decision-maker service " .. domain .. ": " .. err )
    else
      if decision_maker.path ~= nil then
        decision_maker_path = decision_maker.path
      end
      connected = true
      break
    end
  end

  if connected == false then
    kong.log.err("Could not connect to any decision-maker service")
    return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
  end

  local res, err = client:request {
    method = request_method,
    path = decision_maker_path .. request_path,
    body = request_body,
    headers = request_headers
  }

  if not res then
    kong.log.err("Could not receive any data from decision-maker service: " .. err)
    return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
  end

  local response_status = res.status
  local response_content = res:read_body()
  return response_status, response_content
end


function DecisionMakerHandler:access(conf)
  DecisionMakerHandler.super.access(self)
  local status_code, content = make_decision(conf)
  if status_code ~= 200 or status_code ~= 201 then
    return kong.response.exit(status_code, content)
  end
end


return DecisionMakerHandler