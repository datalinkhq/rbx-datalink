local ServerStorage = game:GetService("ServerStorage")

local DATALINK_DEVELOPER_ACCOUNT_ID = 3
local DATALINK_DEVELOPER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiMzhiYzk2ZGYtODQ4Mi00NGFlLTg3MDMtMWNiMGFkZDJiNzk5IiwiaWF0IjoxNjcwMTkzODE3fQ.efzw5tHOZBrTmfJeAjuuhELHI6z2F7GR8w7y8SXB1v8"

return function()
	local DatalinkSDK = require(ServerStorage.DatalinkSDK)
	local Datalink

	describe("Authenticate with Datalink Developer account", function()
		FOCUS()

		it("Should have no exceptions raised on construction of the Datalink Instance", function()
			Datalink = DatalinkSDK.new({
				datalinkUserAccountId = DATALINK_DEVELOPER_ACCOUNT_ID,
				datalinkUserToken = DATALINK_DEVELOPER_TOKEN
			})

			expect(Datalink).to.be.ok()
		end)

		it("Should authenticate the Datalink Developer account w/o error", function()
			if not Datalink:isAuthenticated() then
				local success = Datalink:authenticateAsync():await()

				expect(success).to.equal(true)
			end

			expect(true).to.equal(true)
		end)
	end)
end