--!nocheck 

--[[
	RBX-DataLink - The Lua Module used in wrapping the DataLink website interface
]]--

-- // Services

-- // Constants
local DATALINK_DEBUG_MODE = true

-- // Modules
local DataLinkTypes = require(script.Types)

local HttpModule = require(script.Classes.Http)
local BuilderModule = require(script.Classes.Builder)
local ConsoleModule = require(script.Classes.Console)
local AuthenticatorModule = require(script.Classes.Authenticator)

-- // Variables
local DataLink: DataLinkTypes.DataLinkClass = {
	Authenticator = AuthenticatorModule,

	_debugEnabled = DATALINK_DEBUG_MODE,

	_types = script.Types,
	_enums = require(script.Constants.Enumerations),
	_urlResolves = require(script.Constants.URLResolves),
	_errorMessages = require(script.Constants.ErrorMessages),
}

function DataLink.initialise(authenticatorClass: userdata): nil
	if DataLink._initialised then
		return false, "DataLink Analytics is already initialized"
	end

	DataLink._key = authenticatorClass.key
	DataLink._id = authenticatorClass.id

	DataLink._console = DataLink._console or ConsoleModule.new(DataLink)
	DataLink._builder = DataLink._builder or BuilderModule.new(DataLink)
	DataLink._http = DataLink._http or HttpModule.new(DataLink)

	if not DataLink._http.HttpEnabled then
		return false, DataLink._http.HttpError
	end

	DataLink._console:log("Successfully initialized")
	DataLink._initialised = true

	return true
end

return DataLink