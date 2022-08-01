local ServerStorage = game:GetService("ServerStorage")

local DatalinkService = require(ServerStorage.DatalinkService)

local REQUEST_SIZE = 1

local customEventTest = { }

function customEventTest.countDownFrom(x)
	for index = 1, x do
		print(script.Name, x - index)

		task.wait(1)
	end
end

function customEventTest.run()
	for index = 1, REQUEST_SIZE do
		task.spawn(function()
			DatalinkService:FireLogEvent("error", "Error Message", "Error Trace"):Then(function()
				print("Completed:", index)
			end)
		end)
	end

	return true
end

return customEventTest