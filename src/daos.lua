local typedefs = require "kong.db.schema.typedefs"


local name_type = typedefs.name
name_type.required = true
local scheme_type = typedefs.protocol
scheme_type.default = "https"
local host_type = typedefs.host
host_type.required = true
local port_type = typedefs.port
port_type.default = 80
local path_type = typedefs.path
path_type.default = "/decisions"


return {
  decision_makers = {
    name = "decision_makers",
    endpoint_key = "name",
    primary_key = { "id" },
    cache_key = { "name" },
    generate_admin_api = true,
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },
      { name = name_type },
      { scheme = scheme_type },
      { host = host_type },
      { port = port_type },
      { path = path_type },
    }
  }
}