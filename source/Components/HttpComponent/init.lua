local HttpService = game:GetService("HttpService")

local HTTPS_LOOPBACK_ADDRESS = "127.0.0.1"
local HTTPS_RESOURCE_ERROR = "HttpService is not allowed to access ROBLOX resources"

return function(datalinkInstance)
	local ThrottleComponent = datalinkInstance.Internal:getComponent("ThrottleComponent")
	local SchedulerComponent = datalinkInstance.Internal:getComponent("SchedulerComponent")

	local EndpointPaths = require(datalinkInstance.Data.EndpointPaths)
	local EndpointMethods = require(datalinkInstance.Data.EndpointMethods)
	local DatalinkSchema = require(datalinkInstance.Data.DatalinkSchema)

	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)
	local SchemaType = require(datalinkInstance.Enums.SchemaType)

	local Promise = require(datalinkInstance.Submodules.Promise)
	local Sift = require(datalinkInstance.Submodules.Sift)

	local HttpComponent = { }

	HttpComponent.DefaultHeaders = { }
	HttpComponent.HttpEnabled = select(2, pcall(HttpService.GetAsync, HttpService, HTTPS_LOOPBACK_ADDRESS)) == HTTPS_RESOURCE_ERROR

	HttpComponent.Interface = { }
	HttpComponent.Internal = { }

	function HttpComponent.Internal:addDefaultRequestHeader(headerKey, headerValue)
		HttpComponent.DefaultHeaders[headerKey] = headerValue
	end

	function HttpComponent.Internal:removeDefaultRequestHeader(headerKey)
		HttpComponent.DefaultHeaders[headerKey] = nil
	end

	function HttpComponent.Internal:resolveEndpoint(endpointType)
		local endpointPath = EndpointPaths[endpointType] -- 
		local endpointMethods = EndpointMethods[endpointType]

		local resolvedEndpointName = datalinkInstance.Branch == "Development" and
			string.format(DatalinkSchema[SchemaType.Model], DatalinkSchema[SchemaType.ModelUrlOffline], endpointPath) or
			string.format(DatalinkSchema[SchemaType.Model], DatalinkSchema[SchemaType.ModelUrlOnline], endpointPath)

		return resolvedEndpointName, endpointMethods
	end

	function HttpComponent.Interface:requestPriorityAsync(endpointType, requestBody, requestHeaders)
		local targetEndpointUrl, targetMethod = HttpComponent.Internal:resolveEndpoint(endpointType)

		return Promise.new(function(resolve, reject)
			if not HttpComponent.HttpEnabled then
				reject("Http requests are not enabled. Enable via game settings ")
			end

			local success, response = SchedulerComponent:addTaskAsync(function()
				return HttpService:RequestAsync({
					[HttpsParameters.Headers] = Sift.Dictionary.mergeDeep(HttpComponent.DefaultHeaders, requestHeaders),
					[HttpsParameters.Url] = targetEndpointUrl,
					[HttpsParameters.Method] = targetMethod,
					[HttpsParameters.Body] = HttpService:JSONEncode(Sift.Dictionary.mergeDeep({
						[HttpsParameters.Token] = datalinkInstance.serverAuthenticationKey or datalinkInstance._settings.datalinkUserToken,
						[HttpsParameters.Id] = datalinkInstance._settings.datalinkUserAccountId
					}, requestBody))
				})
			end, true):await()

			if success then
				datalinkInstance.onMessageRequestSent:Fire(endpointType)

				resolve(response)
			else
				datalinkInstance.onMessageRequestFail:Fire(response)

				reject(response)
			end
		end)
	end

	function HttpComponent.Interface:requestAsync(endpointType, requestBody, requestHeaders)
		local targetEndpointUrl, targetMethod = HttpComponent.Internal:resolveEndpoint(endpointType)

		return Promise.new(function(resolve, reject)
			if not HttpComponent.httpEnabled then
				reject("Http requests are not enabled. Enable via game settings ")
			end

			while ThrottleComponent:isThrottled() do
				task.wait(1)
			end

			local success, response = SchedulerComponent:addTaskAsync(function()
				return HttpService:RequestAsync({
					[HttpsParameters.Headers] = Sift.Dictionary.mergeDeep(HttpComponent.DefaultHeaders, requestHeaders),
					[HttpsParameters.Url] = targetEndpointUrl,
					[HttpsParameters.Method] = targetMethod,
					[HttpsParameters.Body] = HttpService:JSONEncode(Sift.Dictionary.mergeDeep({
						[HttpsParameters.Token] = datalinkInstance.serverAuthenticationKey or datalinkInstance._settings.datalinkUserToken,
						[HttpsParameters.Id] = datalinkInstance._settings.datalinkUserAccountId
					}, requestBody))
				})
			end):await()

			ThrottleComponent:increment()

			if success then
				datalinkInstance.onMessageRequestSent:Fire(endpointType)

				resolve(response)
			else
				datalinkInstance.onMessageRequestFail:Fire(response)

				reject(response)
			end
		end)
	end

	function HttpComponent.Interface:start()
		HttpComponent.Internal:addDefaultRequestHeader("Content-Type", "application/json; charset=utf-8")

		HttpComponent.Internal:addDefaultRequestHeader("Datalink-Version", datalinkInstance.Version)
		HttpComponent.Internal:addDefaultRequestHeader("Datalink-Branch", datalinkInstance.Branch)
	end

	return HttpComponent.Interface
end