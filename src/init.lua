--[[
	DatalinkService.lua
]]

-- // Services
local RunService = game:GetService("RunService")

-- // Constants
local TIME_BEFORE_YIELD_WARNING = 5

local DATALINK_DEBUG_NAME = "DataLink.Debug"
local DATALINK_BRANCH_NAME = "DataLink.Branch"
local DATALINK_VERSION_NAME = "DataLink.Version"
local DATALINK_VERBOSE_LOGGING_NAME = "DataLink.VerboseLogging"

local IS_SERVER = RunService:IsServer()

-- // Modules
local Signal = require(script.Modules.Imports.Signal)
local ISODate = require(script.Modules.Imports.ISODate)
local Promise = require(script.Modules.Imports.Promise)

local DatalinkTypes = require(script.Parent.Types)
local DatalinkCache = { }
local DatalinkVariables = { }
local DatalinkClasses = {
	"Console", "Throttle", "Queue", "Https", "Session", "Profiler", "Controller"
}

-- // Variables
local DatalinkService: DatalinkTypes.DatalinkClass = { }

-- // Functions
--[=[
	Yields the active thread until DataLink is authenticated
]=]
function DatalinkService:YieldUntilDataLinkIsAuthenticated()
	local timePassed, hasWarned = 0, false
	local callingFunctionName, callingSource =  debug.info(2, "ns")

	callingSource = string.split(callingSource, ".")
	callingSource = callingSource[#callingSource]

	while not DatalinkService.isAuthenticated do
		timePassed += task.wait()

		if not hasWarned and timePassed > TIME_BEFORE_YIELD_WARNING then
			hasWarned = true

			warn(string.format("Infinite yield possible on '%s.%s(...)'", callingSource, callingFunctionName))
		end
	end
end

--[=[
	Fires a custom event with a custom event name and data

	@param eventCategory string
	@param ... any
	@return Promise
]=]
function DatalinkService:FireCustomEvent(eventCategory, ...)
	DatalinkService:YieldUntilDataLinkIsAuthenticated()


	local eventParameters = { ... }
	return Promise.new(function(promiseObject)
		local success, response = DatalinkService.Https.RequestAsync(
			DatalinkService.Constants.Enums.Endpoint.Publish, {
				ServerID = (game.JobId ~= "" and game.JobId) or "0000000000000000",
				DateISO = ISODate.new(),
				PlaceID = game.PlaceId,
				Packet = {
					EventName = eventCategory,
					EventParams = eventParameters
				}
			}
		)

		DatalinkService.Console:Log("FireCustomEvent :", eventCategory, "[", response, "]")

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end)()
end

--[=[
	Fire a log event used to track errors and warnings experienced by players

	@param logLevel Enum.AnalyticsLogLevel
	@param message string
	@param trace string
	@return Promise
]=]
function DatalinkService:FireLogEvent(logLevel, message, trace)
	DatalinkService:YieldUntilDataLinkIsAuthenticated()

	if not DatalinkService:GetVariable(DATALINK_DEBUG_NAME) and IS_SERVER then
		return
	end

	assert(logLevel.EnumType == Enum.AnalyticsLogLevel, "Expected Enum.AnalyticsLogLevel, got " .. type(logLevel))

	return Promise.new(function(promiseObject)
		local success, response = DatalinkService.Https.RequestAsync(
			DatalinkService.Constants.Enums.Endpoint.Log, {
				message = message,
				trace = trace,
				type = logLevel.Name
			}
		)

		DatalinkService.Console:Log("FireLogEvent [", response, "]")

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end)()
end

--[=[
	API used to fire internal datalink events regarding game & player state

	@param internalEnum string
	@param ... any
	@return Promise
]=]
function DatalinkService:FireInternalEvent(internalEnum, body)
	DatalinkService:YieldUntilDataLinkIsAuthenticated()

	if not DatalinkService:GetVariable(DATALINK_DEBUG_NAME) and IS_SERVER then
		return
	end

	return Promise.new(function(promiseObject)
		local success, response = DatalinkService.Https.RequestAsync(internalEnum, body)

		DatalinkService.Console:Log("FireInternalEvent :", internalEnum, "[", response, "]")

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end)()
end

--[=[
	Fire an event used to track player actions pertaining to the in-game economy

	@param player Player
	@param economyAction Enum.AnalyticsEconomyAction
	@param ... any
	@return Promise
]=]
function DatalinkService:FireEconomyEvent(economyAction, ...)

end

--[=[
	Fire an event used to track player progression through the game

	@param player Player
	@param category string
	@param progressionStatus Enum.AnalyticsProgressionStatus
	@param ... any
	@return Promise
]=]
function DatalinkService:FireProgressionEvent(category, progressionStatus, ...)

end

--[=[
	Returns a int defining the state of a fast flag

	@param featureName string
	@param default number
	@return number
]=]
function DatalinkService:GetFastInt(featureName, default)
	return Promise.new(function(promiseObject)
		local success, response = DatalinkService.Https.RequestAsync(
			DatalinkService.Constants.Enums.Endpoint.FlagFetch, {
				name = featureName
			}
		)

		DatalinkService.Console:Log("GetFastInt :", featureName, "[", response, "]")

		promiseObject:Resolve((success and response) or default, success, response)
	end)():Await()
end

--[=[
	Validate if a feature is enabled for this server

	@param featureName string
	@return boolean
]=]
function DatalinkService:GetFastFlag(featureName, ignoreCache)
	if not ignoreCache and DatalinkCache[featureName] then
		return DatalinkCache[featureName]
	end

	local featureInt = DatalinkService:GetFastInt(featureName, 1)
	local uniqueValue = 0

	for _, byteValue in { string.byte(game.JobId, 1, #game.JobId) } do
		uniqueValue += byteValue
	end

	if featureInt == 0 then
		return true
	else
		return uniqueValue % (1 / featureInt) ~= 0
	end
end

--[=[
	Set the state of verbose logging

	@param state boolean
]=]
function DatalinkService:SetVerboseLogging(state)
	DatalinkService:SetVariable(DATALINK_VERBOSE_LOGGING_NAME, state)
end

--[=[
	Set a DataLink Variable, mostly used for internal management, but can be taken advantage of from foreign systems

	@param name string
	@param value any
]=]
function DatalinkService:SetVariable(name, value)
	DatalinkVariables[name] = value
end

--[=[
	Get a DataLink Variable, mostly used for internal management, but can be taken advantage of from foreign systems

	@param name string
	@param value any
]=]
function DatalinkService:GetVariable(name)
	return DatalinkVariables[name]
end

--[=[
	Initialization function for the DatalinkService

	@param developerId string -- Your DeveloperID
	@param developerKey string -- Your DeveloperKey
]=]
function DatalinkService:Initialize(developerId, developerKey)
	assert(not DatalinkService.isAuthenticated, DatalinkService.Constants.Errors.Initialized)

	DatalinkService.developerKey = developerKey
	DatalinkService.developerId = developerId

	for _, className in DatalinkClasses do
		DatalinkService[className].init(DatalinkService)
	end

	DatalinkService.Https.Authenticate()
	DatalinkService.isAuthenticated = true
end

--[=[
	@class DatalinkService

	DatalinkService
]=]
--[=[
	@prop isAuthenticated boolean
	@within DatalinkService
]=]
--[=[
	@prop onAuthenticated RBXScriptSignal
	@within DatalinkService
]=]
--[=[
	@prop onRequestFailed RBXScriptSignal
	@within DatalinkService
]=]
--[=[
	@prop onRequestSuccess RBXScriptSignal
	@within DatalinkService
]=]
function DatalinkService.new()
	local serviceProxy = newproxy(true)
	local serviceMetatable = getmetatable(serviceProxy)

	DatalinkService.isAuthenticated = false

	DatalinkService.onAuthenticated = Signal.new()
	DatalinkService.onRequestFailed = Signal.new()
	DatalinkService.onRequestSuccess = Signal.new()

	DatalinkService.Constants = require(script.Modules.Constants)
	DatalinkService.Console = require(script.Modules.Console)
	DatalinkService.Throttle = require(script.Modules.Throttle)
	DatalinkService.Queue = require(script.Modules.Queue)
	DatalinkService.Https = require(script.Modules.Https)
	DatalinkService.Session = require(script.Modules.Session)
	DatalinkService.Profiler = require(script.Modules.Profiler)

	DatalinkService.Controller = require(script.Controller)

	DatalinkService:SetVariable(DATALINK_DEBUG_NAME, true)
	DatalinkService:SetVariable(DATALINK_BRANCH_NAME, "Stable")
	DatalinkService:SetVariable(DATALINK_VERSION_NAME, "0.5")
	DatalinkService:SetVariable(DATALINK_VERBOSE_LOGGING_NAME, true)

	serviceMetatable.__index = DatalinkService
	serviceMetatable.__newindex = DatalinkService
	function serviceMetatable.__tostring()
		return "DatalinkService"
	end

	return serviceProxy
end

return DatalinkService.new()