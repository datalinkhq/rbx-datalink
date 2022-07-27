local ServerStorage = game:GetService("ServerStorage")

local DataLink = require(ServerStorage.DataLink)

local customEventTest = { }

function customEventTest.countDownFrom(x)
	for index = 1, x do
		print(script.Name, x - index)

		task.wait(1)
	end
end

function customEventTest.run()
	customEventTest.countDownFrom(10)
	DataLink.FireCustomEvent("EventExample", "EventData1", { }):Then(function(promise)
		print("ANALYTICS SENT!")

		task.delay(2.5, promise.Retry, promise)
	end):Catch(function(promise, exception)
		print("ANALYTICS FAILED:", exception)

		task.delay(2.5, promise.Retry, promise)
	end)

	print("Custom Event Loop Started!")

	return true
end

return customEventTest