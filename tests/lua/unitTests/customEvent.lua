local ServerStorage = game:GetService("ServerStorage")

local DatalinkService = require(ServerStorage.DatalinkService)

local REQUEST_SIZE = 0

local customEventTest = { }

function customEventTest.run()
	for index = 1, REQUEST_SIZE do
		task.spawn(function()
			DatalinkService:FireCustomEvent("EventExample", "EventData1", { }):Then(function()
				print("Completed:", index)
			end)
		end)
	end

	return true
end

return customEventTest