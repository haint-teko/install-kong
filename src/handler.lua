local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"

local kong = kong
local DecisionMakerHandler = BasePlugin:extend()
local HTTP_500 = 500

DecisionMakerHandler.VERSION = "1.0.0"
DecisionMakerHandler.PRIORITY = 1010

function DecisionMakerHandler:new()
  DecisionMakerHandler.super.init_worker(self, "decision-maker")
end


local function connect(client, host, port)
  local ok, err = client:connect(host, port)
  if not ok then
    local domain = host .. ":" .. port
    kong.log.err("Could not connect to decision-maker service " .. domain ": ", err)
    return false
  end
  return true
end


local function make_decision(conf)
  local request_method = kong.request.get_method()
  local request_path = kong.request.get_path_with_query()
  local request_body = kong.request.get_raw_body()
  local request_headers = kong.request.get_headers()
  local service = kong.router.get_service()
  request_headers["X-Upstream-Host"] = service.host .. ":" .. service.port
  local client = http.new()
  client:set_timeout(conf.timeout)

  local decision_maker
  if conf.decision_maker ~= nil then
    decision_maker = kong.db.decision_makers:select(conf.decision_maker)
    local ok = connect(client, decision_maker.host, decision_maker.port)
    if not ok then
      decision_maker = nil
    end
  end

  if conf.decision_maker == nil or decision_maker == nil then
    for another in kong.db.decision_makers:each() do
      local ok = connect(client, another.host, another.port)
      if ok then
        decision_maker = another
        break
      end
    end
  end

  if decision_maker == nil then
    kong.log.err("Could not connect to any decision-maker service")
    return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
  end

  local path = decision_maker.path or "/decisions"
  request_path = path .. request_path
  local res, err = client:request {
    method = request_method,
    path = request_path,
    body = request_body,
    headers = request_headers
  }

  if not res then
    kong.log.err("Could not receive any data from decision-maker service: ", err)
    return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
  end

  local status_code = res.status
  local content = res:read_body()

  res, err = client:set_keepalive(conf.keepalive)
  if not res then
    kong.log.err("Could not keepalive connection: ", err)
  end

  return status_code, content
end


function DecisionMakerHandler:access(conf)
  DecisionMakerHandler.super.access(self)
  local status_code, content = make_decision(conf)
  if status_code ~= 200 and status_code ~= 201 then
    return kong.response.exit(status_code, content)
  end
end


return DecisionMakerHandler