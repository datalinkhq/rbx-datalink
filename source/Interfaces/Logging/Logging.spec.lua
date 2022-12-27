local ServerStorage = game:GetService("ServerStorage")

local DATALINK_DEVELOPER_TOKEN = _G.DATALINK_DEVELOPER_TOKEN
local DATALINK_DEVELOPER_ACCOUNT_ID = _G.DATALINK_DEVELOPER_ACCOUNT_ID

return function()
	local DatalinkSDK = require(ServerStorage.DatalinkSDK)
	local Datalink

	describe("Invoke all of the 'Logging' interface test methods", function()
		beforeAll(function()
			Datalink = DatalinkSDK.new({
				datalinkUserAccountId = DATALINK_DEVELOPER_ACCOUNT_ID,
				datalinkUserToken = DATALINK_DEVELOPER_TOKEN
			})

			if not Datalink:isAuthenticated() then
				Datalink:authenticateAsync():await()
			end
		end)
	end)
end