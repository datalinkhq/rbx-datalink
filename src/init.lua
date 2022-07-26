--!nocheck 

--[[
	RBX-DataLink - The Lua Module used in wrapping the DataLink website interface
]]--

-- // Types
local DataLinkTypes = require(script.Types)

-- // Modules
local AuthenticatorModule = require(script.Modules.Authenticator)
local PromiseModule = require(script.Modules.Promise)
local SignalModule = require(script.Modules.Signal)

-- // Classes
local HeartbeatModule = require(script.Classes.Heartbeat)
local SchedulerModule = require(script.Classes.Scheduler)
local HttpsModule = require(script.Classes.Https)
local IOModule = require(script.Classes.IO)

-- // Modules
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
	SignalModule = SignalModule
}

function DataLink.FireCustomEvent(eventCategory: string, ...: any): DataLinkTypes.PromiseClass
	assert(DataLink.isAuthenticated, "DataLink.FireCustomEvent requires DataLink to be authenticated!")
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

	return DataLink.internal.Heartbeat:Heartbeat()
end

return DataLink