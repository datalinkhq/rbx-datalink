local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local customEventTest = { }

function customEventTest.await()
	if not DataLink.isInitialised then
		return DataLink.onInitialised:Wait()
	end
end

function customEventTest.run()
	customEventTest.await()

	DataLink.fireCustomEvent("EventExample", "EventData1", { })

	return true
end

return customEventTest