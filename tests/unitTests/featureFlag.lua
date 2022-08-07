local ServerStorage = game:GetService("ServerStorage")

local DatalinkService = require(ServerStorage.DatalinkService)

local FAST_FLAGS = {
	"ExampleFlag"
}

local fastFlagTest = { }

function fastFlagTest.run()
	for _, flagName in FAST_FLAGS do
		print(flagName, DatalinkService:GetFastFlag(flagName))
	end

	return true
end

return fastFlagTest