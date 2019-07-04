local endpoints = require "kong.api.endpoints"
local decision_makers_schema = kong.db.decision_makers.schema


return {
  ["/decision-makers/"] = {
    schema = decision_makers_schema,
    methods = {

    }
  }
}