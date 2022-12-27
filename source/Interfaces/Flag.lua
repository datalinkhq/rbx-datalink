local HttpService = game:GetService("HttpService")

return function(datalinkInstance)
	local Promise = require(datalinkInstance.Submodules.Promise)

	local EndpointType = require(datalinkInstance.Enums.EndpointType)
	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)
	local HTTPExceptionCodes = require(datalinkInstance.Data.HTTPExceptionCodes)

	local Flag = { }

	Flag.Interface = { }

	function Flag.Interface:getAllFastFlagsAsync()
		return Promise.new(function(resolve, reject)
			local HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")
			local success, response = HttpComponent:requestAsync(EndpointType.FetchFlagInt):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON)
			else
				reject(statusMessage)
			end
		end)
	end

	function Flag.Interface:getFastIntAsync()
		
	end

	function Flag.Interface:getFastFlagAsync()
		
	end

	return Flag.Interface
end