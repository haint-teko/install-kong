local BasePlugin = require "kong.plugins.base_plugin"
local DecisionMakerHandler = BasePlugin:extend()
local kong = kong

DecisionMakerHandler.VERSION = "1.0.0"
DecisionMakerHandler.PRIORITY = 1010


function DecisionMakerHandler:new()
  DecisionMakerHandler.super.init_worker(self, "decision-maker")
end


function DecisionMakerHandler:access(config)
  DecisionMakerHandler.super.access(self)
end


return DecisionMakerHandler