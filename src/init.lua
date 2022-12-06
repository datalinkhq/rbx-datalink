local HttpService = game:GetService("HttpService")

local DatalinkSDK = { }
local DatalinkVariables = { }
local DatalinkInstance

DatalinkSDK.Data = script.Data
DatalinkSDK.Enums = script.Enums
DatalinkSDK.Submodules = script.Submodules
DatalinkSDK.Components = script.Components

DatalinkSDK._version = "1.0.0"
DatalinkSDK._branch = "Development"

local Type = require(script.Type)

local Sift = require(DatalinkSDK.Submodules.Sift)
local Promise = require(DatalinkSDK.Submodules.Promise)
local Signal = require(DatalinkSDK.Submodules.Signal)

local EndpointType = require(DatalinkSDK.Enums.EndpointType)
local HttpsParameters = require(DatalinkSDK.Enums.HttpsParameters)
local HTTPExceptionCodes = require(DatalinkSDK.Data.HTTPExceptionCodes)

function DatalinkSDK:_getComponent(componentName)
	for _, componentResolve in self._components do
		if componentResolve.name ~= componentName then
			continue
		end

		return componentResolve :: typeof(componentResolve)
	end
end

function DatalinkSDK:_invokeComponentMethod(method, ...)
	for _, componentResolve in self._components do
		if componentResolve[method] then
			componentResolve[method](componentResolve, ...)
		end
	end
end

function DatalinkSDK:_registerComponentModules()
	for _, componentObject in self.Components:GetChildren() do
		local componentResolve = require(componentObject)

		table.insert(self._components, componentResolve)

		if not componentResolve.name then
			componentResolve.name = componentObject.Name
		end
	end
end

function DatalinkSDK:fireCustomEvent()
	
end

function DatalinkSDK:fireEconomyEvent()
	
end

function DatalinkSDK:fireProgressionEvent()
	
end

function DatalinkSDK:setVerboseLogging(state)
	self:setLocalVariable("Internal.VerboseLoggingEnabled", state)
end

function DatalinkSDK:setLocalVariable(variableName, variableValue)
	DatalinkVariables[variableName] = variableValue
end

function DatalinkSDK:getLocalVariable(variableName)
	return DatalinkVariables[variableName]
end

function DatalinkSDK:getLocalVariables()
	return DatalinkVariables
end

function DatalinkSDK:getFastIntAsync()
	
end

function DatalinkSDK:getAllFastFlagsAsync()
	-- return Promise.new(function(resolve, reject)
	-- 	local HttpComponent = self:_getComponent("HttpComponent")
	-- 	local success, response = HttpComponent:requestAsync(EndpointType.FetchFlagInt):await()

	-- 	if not success then
	-- 		reject(response)
	-- 	end

	-- 	local responseBody = response[HttpsParameters.Body]
	-- 	local statusCode = response[HttpsParameters.StatusCode]
	-- 	local statusMessage = HTTPExceptionCodes[statusCode] or response[HttpsParameters.Status]

	-- 	warn("AllFastFlags:", responseBody)

	-- 	if statusCode == 200 then
	-- 		local bodyJSON = HttpService:JSONDecode(responseBody)

			
	-- 	else
	-- 		reject(statusMessage)
	-- 	end
	-- end)
end

function DatalinkSDK:getFastFlagAsync(flagId)
	
end

function DatalinkSDK:authenticateAsync()
	return Promise.new(function(resolve, reject)
		local SessionComponent = self:_getComponent("SessionComponent")

		SessionComponent:authenticateServerAsync():andThen(function()
			self.onAuthenticated:Fire(self.serverAuthenticationKey)
			SessionComponent:spawnHeartbeatDaemon()

			resolve()
		end):catch(function(...)
			reject(...)
		end)
	end)
end

function DatalinkSDK:isAuthenticated()
	return self.serverAuthenticationKey ~= nil
end

function DatalinkSDK.new(datalinkSettings): Type.DatalinkInstance
	if DatalinkInstance then
		return DatalinkInstance
	end

	local self = setmetatable({
		_components = { },
		_settings = table.freeze(Sift.Dictionary.mergeDeep({
			datalinkUserAccountId = 0,
			datalinkUserToken = ""
		}, datalinkSettings)),

		onAuthenticated = Signal.new()
	}, {
		__index = DatalinkSDK
	})

	self:_registerComponentModules()

	self:_invokeComponentMethod("init", self)
	self:_invokeComponentMethod("start", self)

	self:setVerboseLogging()

	table.freeze(self._components)

	self._proxy = newproxy(true)
	self._object = self

	getmetatable(self._proxy).__index = function(_, key)
		return self[key]
	end

	DatalinkInstance = self._proxy

	return self._proxy :: typeof(self)
end

return DatalinkSDK :: Type.DatalinkSDK