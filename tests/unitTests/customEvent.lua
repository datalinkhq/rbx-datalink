local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local customEventTest = { }

function customEventTest.await()
	if not DataLink.isAuthenticated then
		return DataLink.onAuthenticated:Wait()
	end
end

function customEventTest.run()
	customEventTest.await()

	DataLink.FireCustomEvent("EventExample", "EventData1", { })

	return true
end

return customEventTest