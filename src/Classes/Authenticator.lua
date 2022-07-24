--[[

]]--

-- // Modules
local Constants = script.Parent.Parent.Constants
local ErrorMessages = require(Constants.ErrorMessages)

-- // Constants
local KEY_LENGTH_INT = 36

-- // Variables
local Authenticator = { }

function Authenticator.new(id, key)
	assert(#key == KEY_LENGTH_INT, ErrorMessages.InvalidKey)

	local authenticatorProxy = newproxy(true) 
	local authenticatorMetatable = getmetatable(authenticatorProxy)

	authenticatorMetatable.__metatable = "The metatable is locked"
	authenticatorMetatable.__index = table.freeze(setmetatable(
		{ id = id, key = key },
		{ __index = Authenticator }
	))

	function authenticatorMetatable:__tostring()
		return "AuthenticatorClass :: DataLink"
	end

	return authenticatorProxy
end

return Authenticator