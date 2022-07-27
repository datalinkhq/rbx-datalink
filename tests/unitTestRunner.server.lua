local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local DEVELOPER_ID = 10
local DEVELOPER_GAME_KEY = "80eff350-97f0-4bba-9dae-fe36e0f5d2bd"

DataLink.onRequestFailed:Connect(function(...)
	DataLink.internal.IO:Write(DataLink.internal.Enums.IOType.Warn, "Unit-RequestFailed", ...)
end)

-- DataLink.onRequestSuccess:Connect(function(...)
-- 	DataLink.internal.IO:Write(DataLink.internal.Enums.IOType.Log, "Unit-RequestSuccess", ...)
-- end)

local function runUnitModule(unitModule)
	local success, message = unitModule.run(DEVELOPER_ID, DEVELOPER_GAME_KEY)

	if not success then
		return warn(string.format("[UnitTest %s]: Fail (%s)", unitModule.Name, message or "<Unknown error>"))
	end
end

for _, unitTestModule in script.Parent.unitTests:GetChildren() do
	local unitModule = require(unitTestModule)

	task.spawn(runUnitModule, unitModule)
end