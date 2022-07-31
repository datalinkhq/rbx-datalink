--[[
	DatalinkService.lua
]]

-- // Constants
local TIME_BEFORE_YIELD_WARNING = 5

-- // Modules
local Signal = require(script.Modules.Imports.Signal)
local ISODate = require(script.Modules.Imports.ISODate)
local Promise = require(script.Modules.Imports.Promise)

local DatalinkTypes = require(script.Types)
local DatalinkClasses = {
	"Console", "Throttle", "Queue", "Https", "Session"
}

-- // Variables
local DatalinkService: DatalinkTypes.DataLinkClass = { }

-- // Functions
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

		self.Console:Log("FireCustomEvent [", response, "]")

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end)()
end

function DatalinkService:FireLogEvent()
	
end

function DatalinkService:FireEconomyEvent()
	
end

function DatalinkService:FireProgressionEvent()
	
end

function DatalinkService:Initialize(developerId, developerKey)
	assert(not self.isAuthenticated, self.Constants.Errors.Initialized)

	self.developerKey = developerKey
	self.developerId = developerId

	for _, className in DatalinkClasses do
		self[className].init(self)
	end

	for _, controller in script.Controllers:GetChildren() do
		require(controller).new(self)
	end

	self.Https.Authenticate()
	self.isAuthenticated = true
end

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

	serviceMetatable.__index = self
	serviceMetatable.__newindex = self
	function serviceMetatable.__tostring()
		return "DatalinkService"
	end

	return self -- serviceProxy
end

return DatalinkService.new()