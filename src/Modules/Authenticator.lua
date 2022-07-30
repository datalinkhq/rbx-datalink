--[[

]]--

-- // Modules
local Constants = script.Parent.Parent.Constants
local Errors = require(Constants.Errors)

-- // Constants
local KEY_LENGTH_INT = 36
local AUTHENTICATOR_NAME = "DataLink-Authenticator"

-- // Variables
local Authenticator = { }

function Authenticator.new(id, key)
	assert(#key == KEY_LENGTH_INT, Errors.InvalidKey)

	local authenticatorProxy = newproxy(true) 
	local authenticatorMetatable = getmetatable(authenticatorProxy)

	id = tostring(id)
	key = tostring(key)

	authenticatorMetatable.__metatable = "The metatable is locked"
	authenticatorMetatable.__index = table.freeze(setmetatable(
		{ id = id, key = key },
		{ __index = Authenticator }
	))

	function authenticatorMetatable:__tostring()
		return AUTHENTICATOR_NAME
	end

	return authenticatorProxy
end

return Authenticator