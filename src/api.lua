local endpoints = require "kong.api.endpoints"
local decision_makers_schema = kong.db.decision_makers.schema


return {
  ["/decision-makers"] = {
    schema = decision_makers_schema,
    methods = {
      GET = endpoints.get_collection_endpoint(decision_makers_schema),
      POST = endpoints.post_collection_endpoint(decision_makers_schema)
    }
  }
}