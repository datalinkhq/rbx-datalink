--[[
	DatalinkService.lua
]]

-- // Services
local RunService = game:GetService("RunService")

-- // Constants
local TIME_BEFORE_YIELD_WARNING = 5
local IS_SERVER = RunService:IsServer()
local IS_DEBBUG_ENABLED = true

-- // Modules
local Signal = require(script.Modules.Imports.Signal)
local ISODate = require(script.Modules.Imports.ISODate)
local Promise = require(script.Modules.Imports.Promise)

local DatalinkTypes = require(script.Types)
local DatalinkCache = { }
local DatalinkClasses = {
	"Console", "Throttle", "Queue", "Https", "Session", "Profiler", "Controller"
}

-- // Variables
local DatalinkService: DatalinkTypes.DataLinkClass = { }

-- // Functions
--[=[
	Yields the active thread until DataLink is authenticated
]=]
function DatalinkService:YieldUntilDataLinkIsAuthenticated()
	local timePassed, hasWarned = 0, false
	local callingFunctionName, callingSource =  debug.info(2, "ns")

	callingSource = string.split(callingSource, ".")
	callingSource = callingSource[#callingSource]

	while not self.isAuthenticated do
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
	self:YieldUntilDataLinkIsAuthenticated()

	local eventParameters = { ... }
	return Promise.new(function(promiseObject)
		local success, response = self.Https.RequestAsync(
			self.Constants.Enums.Endpoint.Publish, {
				ServerID = (game.JobId ~= "" and game.JobId) or "0000000000000000",
				DateISO = ISODate.new(),
				PlaceID = game.PlaceId,
				Packet = {
					EventName = eventCategory,
					EventParams = eventParameters
				}
			}
		)

		self.Console:Log("FireCustomEvent :", eventCategory, "[", response, "]")

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
	self:YieldUntilDataLinkIsAuthenticated()

	if not IS_DEBBUG_ENABLED and IS_SERVER then
		return
	end

	assert(logLevel.EnumType == Enum.AnalyticsLogLevel, "Expected Enum.AnalyticsLogLevel, got " .. type(logLevel))

	return Promise.new(function(promiseObject)
		local success, response = self.Https.RequestAsync(
			self.Constants.Enums.Endpoint.Log, {
				message = message,
				trace = trace,
				type = logLevel.Name
			}
		)

		self.Console:Log("FireLogEvent [", response, "]")

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
	self:YieldUntilDataLinkIsAuthenticated()

	if not IS_DEBBUG_ENABLED and IS_SERVER then
		return
	end

	return Promise.new(function(promiseObject)
		local success, response = self.Https.RequestAsync(internalEnum, body)

		self.Console:Log("FireInternalEvent :", internalEnum, "[", response, "]")

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
function DatalinkService:FireEconomyEvent(player, economyAction, ...)
	
end

--[=[
	Fire an event used to track player progression through the game

	@param player Player
	@param category string
	@param progressionStatus Enum.AnalyticsProgressionStatus
	@param ... any
	@return Promise
]=]
function DatalinkService:FireProgressionEvent(player, category, progressionStatus, ...)
	
end

--[=[
	Returns a int defining the state of a fast flag

	@param featureName string
	@param default number
	@return number
]=]
function DatalinkService:GetFastInt(featureName, default)
	return Promise.new(function(promiseObject)
		local success, response = self.Https.RequestAsync(
			self.Constants.Enums.Endpoint.FlagFetch, {
				name = featureName
			}
		)

		self.Console:Log("GetFastInt :", featureName, "[", response, "]")

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

	local featureInt = self:GetFastInt(featureName, 1)
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
	Initialization function for the DatalinkService

	@param developerId string -- Your DeveloperID
	@param developerKey string -- Your DeveloperKey
]=]
function DatalinkService:Initialize(developerId, developerKey)
	assert(not self.isAuthenticated, self.Constants.Errors.Initialized)

	self.developerKey = developerKey
	self.developerId = developerId

	for _, className in DatalinkClasses do
		self[className].init(self)
	end

	self.Https.Authenticate()
	self.isAuthenticated = true
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
	local self = setmetatable({ }, { __index = DatalinkService })
	local serviceProxy = newproxy(true)
	local serviceMetatable = getmetatable(serviceProxy)

	self.isAuthenticated = false

	self.onAuthenticated = Signal.new()
	self.onRequestFailed = Signal.new()
	self.onRequestSuccess = Signal.new()

	self.Constants = require(script.Modules.Constants)
	self.Console = require(script.Modules.Console)
	self.Throttle = require(script.Modules.Throttle)
	self.Queue = require(script.Modules.Queue)
	self.Https = require(script.Modules.Https)
	self.Session = require(script.Modules.Session)
	self.Profiler = require(script.Modules.Profiler)

	self.Controller = require(script.Controller)

	serviceMetatable.__index = self
	serviceMetatable.__newindex = self
	function serviceMetatable.__tostring()
		return "DatalinkService"
	end

	return self -- serviceProxy
end

return DatalinkService.new()