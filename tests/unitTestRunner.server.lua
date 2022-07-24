local unitTestModules = script.Parent.unitTests:GetChildren()

local DEVELOPER_ID = 2
local DEVELOPER_GAME_KEY = "676af330-ee9c-4084-a7de-3077f3fc66a3"

for unitTestCount, unitTestModule in unitTestModules do
	local unitModule = require(unitTestModule)

	print(string.format("[UnitTest %d - %s]: Initiating", unitTestCount, unitTestModule.Name))
	local success, message = unitModule.run(DEVELOPER_ID, DEVELOPER_GAME_KEY)

	if success then
		print(string.format("[UnitTest %d - %s]: Success", unitTestCount, unitTestModule.Name))
	else
		return warn(string.format("[UnitTest %d - %s]: Fail (%s)", unitTestCount, unitTestModule.Name, message or "???"))
	end
end