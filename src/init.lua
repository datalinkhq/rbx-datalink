--!nocheck 

--[[
	RBX-DataLink - The Lua Module used in wrapping the DataLink website interface
]]--

-- // Constants
local DATALINK_DEBUG_MODE = true

-- // Modules
local DataLinkTypes = require(script.Types)

local PromiseModule = require(script.Modules.Promise)
local SignalModule = require(script.Modules.Signal)

local HttpModule = require(script.Classes.Http)
local BuilderModule = require(script.Classes.Builder)
local ConsoleModule = require(script.Classes.Console)
local AuthenticatorModule = require(script.Classes.Authenticator)

-- // Variables
local DataLink: DataLinkTypes.DataLinkClass = {
	Authenticator = AuthenticatorModule,

	onInitialised = SignalModule.new(),
	initialised = false,

	_debugEnabled = DATALINK_DEBUG_MODE,

	_types = script.Types,
	_enums = require(script.Constants.Enumerations),
	_urlResolves = require(script.Constants.URLResolves),
	_errorMessages = require(script.Constants.ErrorMessages),
}

function DataLink.fireCustomEvent(eventCategory: string, ...: any): DataLinkTypes.PromiseClass
	local rawBodyObject = { ... }
	local httpBody, httpHeaders = DataLink._builder.packet(...), {
		["categoryUuid"] = eventCategory
	}

	DataLink._console:log(DataLink._enums.InvokeSignalType.CustomEvent, eventCategory, ...)
	return PromiseModule.new(function(promise)
		local success, result = DataLink._http.requestAsync(
			DataLink._builder.build(DataLink._enums.Endpoints.Publish),
			DataLink._enums.HTTPMethods.Post,
			httpHeaders, httpBody
		)

		if success then
			promise:Resolve(result)
		else
			promise:Reject(result)
		end
	end):Then(function(_, result)
		DataLink.onRequestSuccess:Fire(DataLink._enums.InvokeSignalType.CustomEvent, result)
	end):Catch(function(_, exception)
		DataLink._console:warn("EventFailure", exception, ":", DataLink._enums.InvokeSignalType.CustomEvent, eventCategory, table.unpack(rawBodyObject))
		DataLink.onRequestFailed:Fire(DataLink._enums.InvokeSignalType.CustomEvent, eventCategory, rawBodyObject)
	end)()
end

function DataLink.fireLogEvent(logLevel: Enum, message: string, ...: any): DataLinkTypes.PromiseClass
	local httpPacket = DataLink._builder.packet(...)
	local httpHeaders = { }

end

function DataLink.fireEconomyEvent(player: Player, economyAction: Enum, ...: any): DataLinkTypes.PromiseClass
	local httpPacket = DataLink._builder.packet(...)
	local httpHeaders = { }

end

function DataLink.fireProgressionEvent(player: Player, category: string, progressionStatus: Enum, ...: any): DataLinkTypes.PromiseClass
	local httpPacket = DataLink._builder.packet(...)
	local httpHeaders = { }

end

function DataLink.initialise(authenticatorClass: userdata): nil
	if DataLink.initialised then
		return false, DataLink._errorMessages.AlreadyInitialised
	end

	DataLink._key = authenticatorClass.key
	DataLink._id = authenticatorClass.id

	DataLink._console = DataLink._console or ConsoleModule.new(DataLink)
	DataLink._builder = DataLink._builder or BuilderModule.new(DataLink)
	DataLink._http = DataLink._http or HttpModule.new(DataLink)

	if not DataLink._http.HttpEnabled then
		return false, DataLink._http.HttpError
	end

	DataLink.onRequestFailed = SignalModule.new()
	DataLink.onRequestSuccess = SignalModule.new()

	DataLink.onInitialised:Fire()

	DataLink.initialised = true
	DataLink._console:log("Successfully initialized")

	return true
end

return DataLink