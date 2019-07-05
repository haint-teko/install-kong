local typedefs = require "kong.db.schema.typedefs"


return {
  name = "decision-maker",
  fields = {
    { protocols = typedefs.protocols_http },
    {
      config = {
        type = "record",
        fields = {
          { decision_maker = {
            type = "foreign",
            reference = "decision_makers",
            default   = ngx.null,
            on_delete = "cascade",
          }, },
          { timeout = {
            type = "number",
            default = 60000,
          }, },
          { keepalive = {
            type = "number",
            default  = 60000
          }, },
    }, }, },
  },
}
