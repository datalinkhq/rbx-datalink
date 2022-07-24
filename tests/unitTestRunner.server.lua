local ServerStorage = game:GetService("ServerStorage")

local DEVELOPER_ID = 2
local DEVELOPER_GAME_KEY = "676af330-ee9c-4084-a7de-3077f3fc66a3"

local DataLink = require(ServerStorage.DataLink)

local unitTestModules = script.Parent.unitTests:GetChildren()

local authenticator = DataLink.Authenticator.new(DEVELOPER_ID, DEVELOPER_GAME_KEY)
local success, result = DataLink.initialise(authenticator)

if success then
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
else
	warn(string.format("[UnitTest-Core]: Fail (%s)", result))
end