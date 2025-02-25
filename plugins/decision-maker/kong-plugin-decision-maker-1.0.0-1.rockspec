package = "kong-plugin-decision-maker"

version = "1.0.0-1"

supported_platforms = {"linux"}

source = { url = "git://github.com/haint-teko/decision-maker" }

description = {
  summary = "A Kong plugin used to integrate with ORY-Oauthkeeper",
  homepage = "https://github.com/teko-vn",
  license = "Apache 2.0"
}

dependencies = {
   "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.decision-maker.handler"] = "src/handler.lua",
    ["kong.plugins.decision-maker.schema"] = "src/schema.lua",
    ["kong.plugins.decision-maker.daos"] = "src/daos.lua",
    ["kong.plugins.decision-maker.migrations"] = "src/migrations/init.lua",
    ["kong.plugins.decision-maker.migrations.000_base_decision_maker"] = "src/migrations/000_base_decision_maker.lua",
    ["kong.plugins.decision-maker.api"] = "src/api.lua"
  }
}