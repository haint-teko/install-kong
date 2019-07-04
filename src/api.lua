local endpoints = require "kong.api.endpoints"
local decision_makers_schema = kong.db.decision_makers.schema
local HTTP_NOT_FOUND = 404


return {
  ["/decision-makers"] = {
    schema = decision_makers_schema,
    methods = {
      GET = endpoints.get_collection_endpoint(decision_makers_schema),
      POST = endpoints.post_collection_endpoint(decision_makers_schema)
    }
  },
  ["/decision-makers/:decision_makers"] = {
    schema = decision_makers_schema,
    methods = {
      before = function(self, db, helpers)
        local judge, _, err_t = endpoints.select_entity(self, db, decision_makers_schema)
        if err_t then
          return endpoints.handle_error(err_t)
        end
        if not judge then
          return kong.response.exit(HTTP_NOT_FOUND, { message = "Decision maker does not exist" })
        end
      end,
      GET  = endpoints.get_entity_endpoint(decision_makers_schema),
      PATCH  = endpoints.patch_entity_endpoint(decision_makers_schema),
      DELETE = endpoints.delete_entity_endpoint(decision_makers_schema),
    }
  }
}