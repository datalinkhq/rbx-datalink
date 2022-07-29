--!nocheck 

--[[
	RBX-DataLink - The Lua Module used in wrapping the DataLink website interface
]]--

-- // Constants
local TIME_BEFORE_YIELD_WARNING = 5

-- // Types
local DataLinkTypes = require(script.Types)

-- // Modules
local AuthenticatorModule = require(script.Modules.Authenticator)
local PromiseModule = require(script.Modules.Promise)
local SignalModule = require(script.Modules.Signal)
local ISODateModule = require(script.Modules.ISODate)

-- // Classes
local HeartbeatModule = require(script.Classes.Heartbeat)
local SchedulerModule = require(script.Classes.Scheduler)
local HttpsModule = require(script.Classes.Https)
local IOModule = require(script.Classes.IO)

-- // Constants
local ErrorModule = require(script.Constants.Errors)
local EnumModule = require(script.Constants.Enums)
local EndpointsModule = require(script.Constants.Endpoints)
local StructModule = require(script.Constants.Struct)

-- // Variables
local DataLink: DataLinkTypes.DataLinkClass = {
	onAuthenticated = SignalModule.new(),
	onRequestFailed = SignalModule.new(),
	onRequestSuccess = SignalModule.new(),

	isAuthenticated = false,

	Authenticator = AuthenticatorModule,
	PromiseModule = PromiseModule,
	SignalModule = SignalModule,
	ISODateModule = ISODateModule
}

function DataLink.YieldUntilDataLinkIsAuthenticated()
	local timePassed, hasWarned = 0, false
	local callingFunctionName, callingSource =  debug.info(2, "ns")

	callingSource = string.split(callingSource, ".")
	callingSource = callingSource[#callingSource]

	while not DataLink.isAuthenticated do
		timePassed += task.wait()

		if not hasWarned and timePassed > TIME_BEFORE_YIELD_WARNING then
			hasWarned = true

			warn(string.format("Infinite yield possible on '%s.%s(...)'", callingSource, callingFunctionName))
		end
	end
end

function DataLink.FireCustomEvent(eventCategory: string, ...: any): DataLinkTypes.PromiseClass
	DataLink.YieldUntilDataLinkIsAuthenticated()

	return DataLink.PromiseModule.new(function(promiseObject)
		local success, response = DataLink.internal.Https:RequestAsync(
			DataLink.internal.Enums.StructType.Publish, {
				ServerID = (game.JobId ~= "" and game.JobId) or "12321321631278",
				PlaceID = (game.PlaceId ~= 0 and game.PlaceId) or -1,
				DateISO = ISODateModule.new(),
				Packet = {
					EventName = eventCategory
				}
			}
		)

		DataLink.internal.IO:Write(DataLink.internal.Enums.IOType.Log, "FireCustomEvent [", response, "]")

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end)()
end

function DataLink.init(authenticatorClass: userdata): nil
	if DataLink.isInitialised then
		return false, ErrorModule.AlreadyInitialised
	end

	DataLink.internal = DataLink.internal or {
		id = authenticatorClass.id,
		token = authenticatorClass.token,

		Enums = EnumModule,
		Errors = ErrorModule,
		Struct = StructModule,
		Endpoint = EndpointsModule
	}

	DataLink.internal.IO = IOModule.new(DataLink)
	DataLink.internal.Https = HttpsModule.new(DataLink)
	DataLink.internal.Scheduler = SchedulerModule.new(DataLink)
	DataLink.internal.Heartbeat = HeartbeatModule.new(DataLink)

	task.spawn(DataLink.internal.Heartbeat.Heartbeat, DataLink.internal.Heartbeat)
	return DataLink.internal.Heartbeat:Authenticate()
end

return DataLink