local ServerStorage = game:GetService("ServerStorage")

local DatalinkService = require(ServerStorage.DatalinkService)

local authenticationTest = { }

function authenticationTest.run(id, key)
	return DatalinkService:Initialize(id, key)
end

return authenticationTest