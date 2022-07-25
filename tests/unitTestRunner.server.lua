local DEVELOPER_ID = 2
local DEVELOPER_GAME_KEY = "676af330-ee9c-4084-a7de-3077f3fc66a3"

local function runUnitModule(unitModule)
	local success, message = unitModule.run(DEVELOPER_ID, DEVELOPER_GAME_KEY)

	if not success then
		return warn(string.format("[UnitTest %s]: Fail (%s)", unitModule.Name, message or "<Unknow message>"))
	end
end

for _, unitTestModule in script.Parent.unitTests:GetChildren() do
	local unitModule = require(unitTestModule)

	task.spawn(runUnitModule, unitModule)
end