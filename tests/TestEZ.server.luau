local ServerScriptService = game:GetService("ServerScriptService")

local Submodules = ServerScriptService:WaitForChild("DatalinkSDK-Submodules")

local TextReporter = require(script.Parent.Reporters.TextReporter)
local TestEZ = require(Submodules.TestEZ)

TestEZ.TestBootstrap:run({ script.Parent.Modules }, TextReporter)