local typedefs = require "kong.db.schema.typedefs"

return {
  decision_makers = {
    name = "decision_makers",
    endpoint_key = "identifier",
    primary_key = { "id" },
    cache_key = { "identifier" },
    fields = {
      { id = typedefs.uuid },
      { identifier = typedefs.name },
      { created_at = typedefs.auto_timestamp_s },
      { scheme = typedefs.http_method },
      { host = typedefs.host },
      { port = typedefs.port },
      { path = typedefs.path },
    }
  }
}