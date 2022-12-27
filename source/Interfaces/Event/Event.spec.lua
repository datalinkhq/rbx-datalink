local DATALINK_DEVELOPER_TOKEN = _G.DATALINK_DEVELOPER_TOKEN
local DATALINK_DEVELOPER_ACCOUNT_ID = _G.DATALINK_DEVELOPER_ACCOUNT_ID

return function()
	local DatalinkSDK = require(script.Parent.Parent)
	local Datalink

	describe("Instantiating & Authenticating datalink class", function()
		it("Should instantiate the datalink object w/o exceptions", function()
			Datalink = DatalinkSDK.new({
				datalinkUserAccountId = DATALINK_DEVELOPER_ACCOUNT_ID,
				datalinkUserToken = DATALINK_DEVELOPER_TOKEN
			})

			expect(Datalink).to.be.ok()
		end)

		it("Should authenticate the datalink object w/o exceptions", function()
			local success = true

			if not Datalink:isAuthenticated() then
				success = Datalink:authenticateAsync():await()
			end

			expect(success).to.equal(true)
		end)
	end)

	describe("Invoke all of the 'Event' interface test methods", function()
		it("Should invoke the 'fireCustomEvent' successfully with 'Parameter1' key set", function()
			local success = Datalink.Event:fireCustomEvent(
				"CustomEventName", {
					Parameter1 = "ParameterValue"
				}
			):await()

			expect(success).to.equal(true)
		end)
	end)
end