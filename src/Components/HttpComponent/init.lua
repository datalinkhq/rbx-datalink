local HttpService = game:GetService("HttpService")

local HTTPS_LOOPBACK_ADDRESS = "127.0.0.1"
local HTTPS_RESOURCE_ERROR = "HttpService is not allowed to access ROBLOX resources"

local Promise
local Sift

local HttpsParameters
local DatalinkSchema, SchemaType

local EndpointPaths
local EndpointMethods

local SchedulerComponent
local ThrottleComponent
local HttpComponent = {
	_defaultHeaders = { }
}

function HttpComponent:_addDefaultRequestHeader(headerKey, headerValue)
	self._defaultHeaders[headerKey] = headerValue
end

function HttpComponent:_removeDefaultRequestHeader(headerKey)
	self._defaultHeaders[headerKey] = nil
end

function HttpComponent:_resolveEndpoint(endpointType)
	local endpointPath = EndpointPaths[endpointType] -- 
	local endpointMethods = EndpointMethods[endpointType]

	local resolvedEndpointName = self._isOfflineWebserver and
		string.format(DatalinkSchema[SchemaType.Model], DatalinkSchema[SchemaType.ModelUrlOffline], endpointPath) or
		string.format(DatalinkSchema[SchemaType.Model], DatalinkSchema[SchemaType.ModelUrlOnline], endpointPath)

	return resolvedEndpointName, endpointMethods
end

function HttpComponent:requestPriorityAsync(endpointType, requestBody, requestHeaders)
	local targetEndpointUrl, targetMethod = self:_resolveEndpoint(endpointType)

	return Promise.new(function(resolve, reject)
		if not self._httpEnabled then
			reject("Http requests are not enabled. Enable via game settings ")
		end

		local serverAuthenticationKey = self._getServerAuthenticationKey()
		local userAuthenticationKey = self._getUserAuthenticationKey()
		local userUniqueIdentifier = self._getUserUniqueIdentifier()
		local sdkBranch = self._getBranchType()

		local success, response = SchedulerComponent:addTaskAsync(function()
			return HttpService:RequestAsync({
				[HttpsParameters.Headers] = Sift.Dictionary.mergeDeep(self._defaultHeaders, requestHeaders),
				[HttpsParameters.Url] = targetEndpointUrl,
				[HttpsParameters.Method] = targetMethod,
				[HttpsParameters.BranchType] = sdkBranch,
				[HttpsParameters.Body] = HttpService:JSONEncode(Sift.Dictionary.mergeDeep({
					[HttpsParameters.Id] = userUniqueIdentifier,
					[HttpsParameters.Token] =
						endpointType == endpointType.Destroy and userAuthenticationKey or
						serverAuthenticationKey or userAuthenticationKey,
				}, requestBody))
			})
		end, true):await()

		if success then
			resolve(response)
		else
			reject(response)
		end
	end)
end

function HttpComponent:requestAsync(endpointType, requestBody, requestHeaders)
	local targetEndpointUrl, targetMethod = self:_resolveEndpoint(endpointType)

	return Promise.new(function(resolve, reject)
		if not self._httpEnabled then
			reject("Http requests are not enabled. Enable via game settings ")
		end

		while ThrottleComponent:isThrottled() do
			task.wait(1)
		end

		local serverAuthenticationKey = self._getServerAuthenticationKey()
		local userAuthenticationKey = self._getUserAuthenticationKey()
		local userUniqueIdentifier = self._getUserUniqueIdentifier()
		local sdkBranch = self._getBranchType()

		local success, response = SchedulerComponent:addTaskAsync(function()
			return HttpService:RequestAsync({
				[HttpsParameters.Headers] = Sift.Dictionary.mergeDeep(self._defaultHeaders, requestHeaders),
				[HttpsParameters.Url] = targetEndpointUrl,
				[HttpsParameters.Method] = targetMethod,
				[HttpsParameters.BranchType] = sdkBranch,
				[HttpsParameters.Body] = HttpService:JSONEncode(Sift.Dictionary.mergeDeep({
					[HttpsParameters.Token] = serverAuthenticationKey or userAuthenticationKey,
					[HttpsParameters.Id] = userUniqueIdentifier
				}, requestBody))
			})
		end):await()

		ThrottleComponent:increment()

		if success then
			resolve(response)
		else
			reject(response)
		end
	end)
end

function HttpComponent:start(SDK)
	self._httpEnabled = select(2, pcall(HttpService.GetAsync, HttpService, HTTPS_LOOPBACK_ADDRESS)) == HTTPS_RESOURCE_ERROR

	function self._getServerAuthenticationKey()
		return SDK.serverAuthenticationKey
	end

	function self._getBranchType()
		return SDK.branch
	end

	function self._getUserAuthenticationKey()
		return SDK._settings.datalinkUserToken
	end

	function self._getUserUniqueIdentifier()
		return SDK._settings.datalinkUserAccountId
	end
end

function HttpComponent:init(SDK)
	EndpointPaths = require(SDK.Data.EndpointPaths)
	EndpointMethods = require(SDK.Data.EndpointMethods)
	DatalinkSchema = require(SDK.Data.DatalinkSchema)

	HttpsParameters = require(SDK.Enums.HttpsParameters)
	SchemaType = require(SDK.Enums.SchemaType)

	Promise = require(SDK.Submodules.Promise)
	Sift = require(SDK.Submodules.Sift)

	ThrottleComponent = SDK:_getComponent("ThrottleComponent")
	SchedulerComponent = SDK:_getComponent("SchedulerComponent")

	self._isOfflineWebserver = SDK.Branch == "Development"

	self:_addDefaultRequestHeader("Content-Type", "application/json; charset=utf-8")

	self:_addDefaultRequestHeader("Datalink-Version", SDK.Version)
	self:_addDefaultRequestHeader("Datalink-Branch", SDK.Branch)
end

return HttpComponent