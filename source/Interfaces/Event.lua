local HttpService = game:GetService("HttpService")

return function(datalinkInstance)
	local HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")
	local DateComponent = datalinkInstance.Internal:getComponent("DateComponent")

	local Promise = require(datalinkInstance.Submodules.Promise)
	local Sift = require(datalinkInstance.Submodules.Sift)

	local EndpointType = require(datalinkInstance.Enums.EndpointType)
	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)
	local HTTPExceptionCodes = require(datalinkInstance.Data.HTTPExceptionCodes)

	local Event = { }

	Event.Interface = { }

	function Event.Interface:fireCustomEvent(eventCategory, eventParameters)
		assert(eventCategory ~= nil, "Expected 'eventCategory' as String")
		assert(eventParameters ~= nil, "Expected 'eventParameters' Dictionary")
		assert(type(eventCategory) == "string", "Expected 'eventCategory' as String")
		assert(type(eventParameters) == "table", "Expected 'eventParameters' as Dictionary")

		local eventParametersAreArray = Sift.Array.is(eventParameters)

		return Promise.new(function(resolve, reject)
			if eventParametersAreArray then
				error("Expected 'eventParameters' type 'Dictionary', got 'Array'")
			end

			local success, response = HttpComponent:requestAsync(EndpointType.PublishCustomEvent, {
				[HttpsParameters.ServerId] = datalinkInstance.Context.placeServerJobId,
				[HttpsParameters.PlaceId] = datalinkInstance.Context.placeServerId,
				[HttpsParameters.DateIso] = DateComponent:fromNow(),
				[HttpsParameters.Packet] = {
					[HttpsParameters.EventName] = eventCategory,
					[HttpsParameters.EventParameters] = eventParameters
				}
			}):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON.EventID)
			else
				reject(statusMessage)
			end
		end)
	end

	function Event.Interface:fireResourceEvent()

	end

	function Event.Interface:fireProgressionEvent()
		
	end

	function Event.Interface:fireEconomyEvent()

	end

	return Event
end