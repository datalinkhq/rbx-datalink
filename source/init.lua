local RunService = game:GetService("RunService")

local DATALINK_CONNECTIONS_JANITOR_INDEX = "InternalConnectionsJanitor"

local Datalink = { }

Datalink.Data = script.Data
Datalink.Enums = script.Enums
Datalink.Submodules = script.Submodules
Datalink.Components = script.Components

Datalink.Version = "1.1.0"
Datalink.Branch = "Development"

Datalink.Instances = { }
Datalink.Interface = { }
Datalink.Schema = { }

local Types = require(script.Types)

local Sift = require(Datalink.Submodules.Sift)
local Promise = require(Datalink.Submodules.Promise)
local Janitor = require(Datalink.Submodules.Janitor)
local Signal = require(Datalink.Submodules.Signal)

local HttpsParameters = require(Datalink.Enums.HttpsParameters)
local EndpointType = require(Datalink.Enums.EndpointType)

function Datalink.Schema:authenticateAsync()
	return Promise.new(function(resolve, reject)
		local SessionComponent = self.Internal:getComponent("SessionComponent")

		SessionComponent:authenticateServerAsync():andThen(function()
			self.onAuthenticated:Fire(self.serverAuthenticationKey)
			SessionComponent:spawnHeartbeatDaemon()

			resolve()
		end):catch(function(...)
			reject(...)
		end)
	end)
end

function Datalink.Schema:isAuthenticated()
	return self.serverAuthenticationKey ~= nil
end

function Datalink.Schema:destroyAsync()
	local HttpComponent = self.Internal:getComponent("HttpComponent")

	return HttpComponent:requestPriorityAsync(EndpointType.Destroy, {
		[HttpsParameters.Token] = self._settings.datalinkUserToken,
		[HttpsParameters.SessionKey] = self.serverAuthenticationKey
	}):andThen(function()
		self._janitor:Destroy()
		self.destroyed = true

		Datalink.Instances[self._settings.datalinkUserToken] = nil
	end)
end

function Datalink.Interface.new(datalinkSettings): Types.DatalinkSchema
	local datalinkInstance = datalinkSettings and Datalink.Instances[datalinkSettings.datalinkUserToken]

	if datalinkInstance then
		return datalinkInstance
	else
		datalinkInstance = setmetatable({
			_variables = { },
			_components = { },
			_janitor = Janitor.new(),
			_connections = Janitor.new(),
			_settings = table.freeze(Sift.Dictionary.mergeDeep({
				datalinkUserAccountId = 0,
				datalinkUserToken = ""
			}, datalinkSettings)),

			onHeartbeat = Signal.new(),
			onAuthenticated = Signal.new(),
			onThrottled = Signal.new(),
			onMessageRequestSent = Signal.new(),
			onMessageRequestFail = Signal.new(),
			onDaemonInitiated = Signal.new()
		}, {
			__index = Datalink.Schema
		})

		datalinkInstance._janitor:Add(datalinkInstance._connections, "Destroy", DATALINK_CONNECTIONS_JANITOR_INDEX)

		datalinkInstance.Internal = require(script.Interfaces.Internal)(datalinkInstance)
		datalinkInstance.Logging = require(script.Interfaces.Logging)(datalinkInstance)
		datalinkInstance.Event = require(script.Interfaces.Event)(datalinkInstance)
		datalinkInstance.Flag = require(script.Interfaces.Flag)(datalinkInstance)

		datalinkInstance.Internal:buildDatalinkComponentInstances()

		datalinkInstance.Internal:invokeComponentMethod("start")

		datalinkInstance.Internal:setLocalVariable("Internal.VerboseLoggingEnabled", false)
		datalinkInstance.Internal:setLocalVariable("Internal.DebugEnabled", true)

		datalinkInstance.Context = {
			placeServerJobId = (game.JobId ~= "" and game.JobId) or "00000000-0000-0000-0000-000000000000",
			placeServerId = (game.PlaceId ~= 0 and game.PlaceId) or -1
		}

		if not RunService:IsRunning() then
			datalinkInstance._janitor:Remove(DATALINK_CONNECTIONS_JANITOR_INDEX)
		end

		table.freeze(datalinkInstance._components)

		Datalink.Instances[datalinkInstance._settings.datalinkUserToken] = datalinkInstance._proxy

		return datalinkInstance.Internal:generateInstanceProxy() :: typeof(datalinkInstance)
	end
end

return Datalink.Interface :: Types.DatalinkInterface