local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local customEventTest = { }

function customEventTest.run()
	DataLink.fireCustomEvent("EventExample", "EventData1", { })

	return true
end

return customEventTest