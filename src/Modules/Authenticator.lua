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

function Authenticator.new(id, token)
	assert(#token == KEY_LENGTH_INT, Errors.InvalidToken)

	local authenticatorProxy = newproxy(true) 
	local authenticatorMetatable = getmetatable(authenticatorProxy)

	id = tostring(id)
	token = tostring(token)

	authenticatorMetatable.__metatable = "The metatable is locked"
	authenticatorMetatable.__index = table.freeze(setmetatable(
		{ id = id, token = token },
		{ __index = Authenticator }
	))

	function authenticatorMetatable:__tostring()
		return AUTHENTICATOR_NAME
	end

	return authenticatorProxy
end

return Authenticator