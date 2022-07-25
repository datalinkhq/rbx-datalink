local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local authenticationTest = { }

function authenticationTest.run(id, key)
	local authenticator = DataLink.Authenticator.new(id, key)

	return DataLink.init(authenticator)
end

return authenticationTest