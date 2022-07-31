local ServerStorage = game:GetService("ServerStorage")

local DatalinkService = require(ServerStorage.DatalinkService)

local customEventTest = { }

function customEventTest.countDownFrom(x)
	for index = 1, x do
		print(script.Name, x - index)

		task.wait(1)
	end
end

function customEventTest.run()
	DatalinkService:FireCustomEvent("EventExample", "EventData1", { })

	return true
end

return customEventTest