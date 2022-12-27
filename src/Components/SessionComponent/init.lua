local HttpService = game:GetService("HttpService")

local INVALID_SESSION_KEY_STATUS = "Session Key Invalid"

return function(datalinkInstance)
	local DaemonComponent = datalinkInstance.Internal:getComponent("DaemonComponent")
	local HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")

	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)
	local EndpointType = require(datalinkInstance.Enums.EndpointType)
	local HeartbeatParameter = require(datalinkInstance.Enums.HeartbeatParameter)

	local HTTPExceptionCodes = require(datalinkInstance.Data.HTTPExceptionCodes)
	local DatalinkHeartbeat = require(datalinkInstance.Data.DatalinkHeartbeat)

	local Promise = require(datalinkInstance.Submodules.Promise)

	local SessionComponent = { }

	SessionComponent.Interface = { }
	SessionComponent.Internal = { }

	function SessionComponent.Internal:onSessionAuthenticationError(response)
		-- TODO: create better error reporter
		local statusCode = response[HttpsParameters.StatusCode]
		local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

		warn(statusMessage, response)
	end

	function SessionComponent.Internal:sessionHeartbeatAuthenticate()
		local success, response = SessionComponent.Interface:authenticateServerAsync():await()

		if not success then
			if not DatalinkHeartbeat[HeartbeatParameter.RetryHeartbeatOnFail] then
				return
			end

			return task.delay(DatalinkHeartbeat[HeartbeatParameter.DelayBeforeRetry], function()
				SessionComponent.Internal:sessionHeartbeatAuthenticate()
			end)
		end

		local responseBody = response[HttpsParameters.Body]
		local bodyJSON = HttpService:JSONDecode(responseBody)

		datalinkInstance.onHeartbeat:Fire(bodyJSON[HttpsParameters.SessionKey])
		datalinkInstance.serverAuthenticationKey = bodyJSON[HttpsParameters.SessionKey]
	end

	function SessionComponent.Internal:sessionHeartbeat()
		local success, response = HttpComponent:requestPriorityAsync(EndpointType.Heartbeat):await()

		if not success then
			SessionComponent.Internal:onSessionAuthenticationError(response)
			task.wait(DatalinkHeartbeat[HeartbeatParameter.DelayBeforeRetry])

			return SessionComponent.Internal:sessionHeartbeat()
		end

		local statusCode = response[HttpsParameters.StatusCode]
		local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

		if statusCode == 401 and statusMessage == INVALID_SESSION_KEY_STATUS then
			SessionComponent.Internal:sessionHeartbeatAuthenticate()
		end
	end

	function SessionComponent.Internal:createDaemonCallback()
		return function()
			while true do
				task.wait(DatalinkHeartbeat[HeartbeatParameter.SessionHeartbeatLifetime])

				SessionComponent.Internal:sessionHeartbeat()
			end
		end
	end

	function SessionComponent.Interface:isSessionActive()
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

	function SessionComponent.Interface:authenticateServerAsync()
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
			datalinkInstance.onHeartbeat:Fire(serverAuthenticationKey)
			datalinkInstance.serverAuthenticationKey = serverAuthenticationKey
		end):catch(function(...)
			SessionComponent.Internal:onSessionAuthenticationError(...)
		end)
	end

	function SessionComponent.Interface:spawnHeartbeatDaemon()
		DaemonComponent:addDaemon(
			SessionComponent.Internal:createDaemonCallback(),
			"SessionHeartbeatValidator",
			true
		)

		game:BindToClose(function()
			datalinkInstance:destroyAsync()
		end)
	end

	return SessionComponent.Interface
end