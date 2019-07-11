local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"

local kong = kong
local DecisionMakerHandler = BasePlugin:extend()
local decision_maker_pool = {}
local HTTP_500 = 500

DecisionMakerHandler.VERSION = "1.0.0"
DecisionMakerHandler.PRIORITY = 1010

function DecisionMakerHandler:new()
  DecisionMakerHandler.super.new(self, "decision-maker")
end

function DecisionMakerHandler:init_worker()
  DecisionMakerHandler.super.init_worker(self)
  for decision_maker in kong.db.decision_makers:each() do
    decision_maker_pool[decision_maker.id] = decision_maker
  end

  kong.worker_events.register(function (data)
    local entity = data.entity
    if data.operation == "create" or data.operation == "update" then
      decision_maker_pool[entity.id] = entity
    end
    if data.operation == "delete" then
      decision_maker_pool[entity.id] = nil
    end
  end, "crud", "decision_makers")
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

local function load_decision_maker(key)
  local decision_makers = decision_maker_pool
  return decision_makers[key]
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
    decision_maker = load_decision_maker(conf.decision_maker.id)
    if decision_maker ~= nil then
      local ok = connect(client, decision_maker.host, decision_maker.port)
      if not ok then decision_maker = nil end
    end
  end

  if conf.decision_maker == nil or decision_maker == nil then
    for _, another in pairs(decision_maker_pool) do
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

  if decision_maker.https == true then
    local ok, err = client:ssl_handshake(false, decision_maker.host, false)
    if not ok then
      kong.log.err("Could not perform SSL handshake: ", err)
      return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
    end
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
  if status_code == 401 or status_code == 403 then
    return kong.response.exit(status_code, content)
  elseif status_code ~= 200 and status_code ~= 201 then
    kong.log.err("Error when making request to decision-maker service: HTTP_", status_code .. ': ', content)
    return kong.response.exit(HTTP_500, { message = "An unexpected error occurred" })
  end
end

return DecisionMakerHandler