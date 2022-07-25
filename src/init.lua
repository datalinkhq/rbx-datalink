--!nocheck 

--[[
	RBX-DataLink - The Lua Module used in wrapping the DataLink website interface
]]--

-- // Services
local HttpService = game:GetService("HttpService")

-- // Types
local DataLinkTypes = require(script.Types)

-- // Modules
local AuthenticatorModule = require(script.Modules.Authenticator)
local PromiseModule = require(script.Modules.Promise)
local SignalModule = require(script.Modules.Signal)

-- // Classes
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
	onInitialised = SignalModule.new(),
	onRequestFailed = SignalModule.new(),
	onRequestSuccess = SignalModule.new(),

	isInitialised = false,

	Authenticator = AuthenticatorModule,
	PromiseModule = PromiseModule,
	SignalModule = SignalModule
}

function DataLink.FireCustomEvent(eventCategory: string, ...: any): DataLinkTypes.PromiseClass
	assert(DataLink.isInitialised, "DataLink.FireCustomEvent requires DataLink to be initialized!")
end

function DataLink.Authenticate()
	return PromiseModule.new(function(promiseObject)
		local success, response = DataLink.internal.Https:RequestAsync(
			DataLink.internal.Enums.StructType.Ping,
			nil, {
				id = DataLink.internal.id,
				token = DataLink.internal.token,
			}
		)

		if success then
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end):Then(function()
		DataLink.onInitialised:Fire()
	end):Catch(function(response)
		DataLink.internal.IO:Write(DataLink.internal.Enums.IOType.Warn, response)
	end)():Await()
end

function DataLink.init(authenticatorClass: userdata): nil
	if DataLink.isInitialised then
		return false, ErrorModule.AlreadyInitialised
	end

	DataLink.internal = DataLink.internal or {
		id = authenticatorClass.id,
		token = authenticatorClass.token,

		Scheduler = SchedulerModule.new(DataLink),
		IO = IOModule.new(DataLink),
		Https = HttpsModule.new(DataLink),

		Enums = EnumModule,
		Errors = ErrorModule,
		Struct = StructModule,
		Endpoint = EndpointsModule
	}

	return DataLink.Authenticate()
end

DataLink.onInitialised:Connect(function()
	DataLink.isInitialised = true
end)

return DataLink