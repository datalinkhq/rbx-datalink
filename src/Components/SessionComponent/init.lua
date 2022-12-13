local HttpService = game:GetService("HttpService")

local INVALID_SESSION_KEY_STATUS = "Session Key Invalid"

local HTTPExceptionCodes
local HttpsParameters

local DatalinkHeartbeat
local HeartbeatParameter

local EndpointType

local Promise

local DaemonComponent
local HttpComponent
local SessionComponent = { }

function SessionComponent:_onSessionAuthenticationError(response)
	-- TODO: create beter error reporter
	local statusCode = response[HttpsParameters.StatusCode]
	local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

	warn(statusMessage, response)
end

function SessionComponent:_sessionHeartbeatAuthenticate()
	local success, response = self:authenticateServerAsync():await()

	if not success then
		if not DatalinkHeartbeat[HeartbeatParameter.RetryHeartbeatOnFail] then
			return
		end

		return task.delay(
			DatalinkHeartbeat[HeartbeatParameter.DelayBeforeRetry],
			self._sessionHeartbeatAuthenticate, self
		)
	end

	local responseBody = response[HttpsParameters.Body]
	local bodyJSON = HttpService:JSONDecode(responseBody)

	self._setServerAuthenticationKey(bodyJSON[HttpsParameters.SessionKey])
end

function SessionComponent:_sessionHeartbeat()
	local success, response = HttpComponent:requestPriorityAsync(EndpointType.Heartbeat):await()

	if not success then
		self:_onSessionAuthenticationError(response)
		task.wait(DatalinkHeartbeat[HeartbeatParameter.DelayBeforeRetry])

		return self:_sessionHeartbeat()
	end

	local statusCode = response[HttpsParameters.StatusCode]
	local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

	if statusCode == 401 and statusMessage == INVALID_SESSION_KEY_STATUS then
		self:_sessionHeartbeatAuthenticate()
	end
end

function SessionComponent:_createDaemonCallback()
	return function()
		while true do
			task.wait(DatalinkHeartbeat[HeartbeatParameter.SessionHeartbeatLifetime])

			self:_sessionHeartbeat()
		end
	end
end

function SessionComponent:isSessionActive()
	return Promise.new(function(resolve, reject)
		local success, response = HttpComponent:requestPriorityAsync(EndpointType.Heartbeat):await()
		if not success then
			reject(response)
		end

		local statusCode = response[HttpsParameters.StatusCode]
		local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

		if statusCode == 200 or statusCode == 401 then
			resolve(statusCode == 200)
		else
			reject(statusMessage)
		end
	end)
end

function SessionComponent:authenticateServerAsync()
	return Promise.new(function(resolve, reject)
		local success, response = HttpComponent:requestPriorityAsync(EndpointType.Authenticate):await()
		if not success then
			reject(response)
		end

		local responseBody = response[HttpsParameters.Body]
		local statusCode = response[HttpsParameters.StatusCode]
		local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

		if statusCode == 200 then
			local bodyJSON = HttpService:JSONDecode(responseBody)

			resolve(bodyJSON[HttpsParameters.SessionKey])
		else
			reject(statusMessage)
		end
	end):andThen(function(serverAuthenticationKey)
		self._setServerAuthenticationKey(serverAuthenticationKey)
	end):catch(function(...)
		self:_onSessionAuthenticationError(...)
	end)
end

function SessionComponent:spawnHeartbeatDaemon()
	DaemonComponent:addDaemon(self:_createDaemonCallback(), "SessionHeartbeatValidator", true)
end

function SessionComponent:start(SDK)
	function self._setServerAuthenticationKey(serverAuthenticationKey)
		SDK.onHeartbeat:Fire(serverAuthenticationKey)
		SDK.serverAuthenticationKey = serverAuthenticationKey
	end
end

function SessionComponent:init(SDK)
	HttpsParameters = require(SDK.Enums.HttpsParameters)
	EndpointType = require(SDK.Enums.EndpointType)
	HeartbeatParameter = require(SDK.Enums.HeartbeatParameter)

	HTTPExceptionCodes = require(SDK.Data.HTTPExceptionCodes)
	DatalinkHeartbeat = require(SDK.Data.DatalinkHeartbeat)

	Promise = require(SDK.Submodules.Promise)

	DaemonComponent = SDK:_getComponent("DaemonComponent")
	HttpComponent = SDK:_getComponent("HttpComponent")
end

return SessionComponent