local HttpService = game:GetService("HttpService")

return function(datalinkInstance)
	local Promise = require(datalinkInstance.Submodules.Promise)

	local EndpointType = require(datalinkInstance.Enums.EndpointType)
	local LogFetchType = require(datalinkInstance.Enums.LogFetchType)
	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)
	local HTTPExceptionCodes = require(datalinkInstance.Data.HTTPExceptionCodes)

	local HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")

	local Logging = { }

	Logging.Interface = { }

	function Logging.Interface:setVerbosity(state)
		datalinkInstance.Internal:setLocalVariable("Internal.VerboseLoggingEnabled", state)
	end

	function Logging.Interface:setLogLevel(level)
		datalinkInstance.Internal:setLocalVariable("Internal.LogLevel", level)
	end

	function Logging.Interface:getExperienceLogsAsync()
		return Promise.new(function(resolve, reject)
			local success, response = HttpComponent:requestAsync(EndpointType.FetchLog, {
				[HttpsParameters.Type] = LogFetchType.Experience
			}):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON.logs)
			else
				reject(statusMessage)
			end
		end)
	end

	function Logging.Interface:getPlaceLogsAsync()
		return Promise.new(function(resolve, reject)
			local success, response = HttpComponent:requestAsync(EndpointType.FetchLog, {
				[HttpsParameters.Type] = LogFetchType.Place
			}):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON.logs)
			else
				reject(statusMessage)
			end
		end)
	end

	function Logging.Interface:getLocalLogsAsync()
		return Promise.new(function(resolve, reject)
			local success, response = HttpComponent:requestAsync(EndpointType.FetchLog, {
				[HttpsParameters.Type] = LogFetchType.Local
			}):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON.logs)
			else
				reject(statusMessage)
			end
		end)
	end

	function Logging.Interface:getLogAsync(logId)
		assert(type(logId) == "number", "Expected 'logId' as Number")

		return Promise.new(function(resolve, reject)
			local success, response = HttpComponent:requestAsync(EndpointType.FetchLog, {
				[HttpsParameters.Type] = LogFetchType.Specific,
				[HttpsParameters.LogId] = logId,
			}):await()

			if not success then
				reject(response)
			end

			local responseBody = response[HttpsParameters.Body]
			local statusCode = response[HttpsParameters.StatusCode]
			local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

			if statusCode == 200 then
				local bodyJSON = HttpService:JSONDecode(responseBody)

				resolve(bodyJSON.logs[1])
			else
				reject(statusMessage)
			end
		end)
	end

	return Logging.Interface
end