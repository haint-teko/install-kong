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
          }, }
    }, }, },
  },
}