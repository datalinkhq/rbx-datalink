local DEVELOPER_ID = 1
local DEVELOPER_GAME_KEY = "cc5055f0-29e1-42d4-923f-11a00760a1a8"

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