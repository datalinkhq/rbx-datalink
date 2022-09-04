--[[
	Console.lua

	This modules function is to provide the DataLink module a handle to what logs it produces
]]--

-- // Constants
local MAX_CACHE_SIZE = 450
local LOG_PREFIX = ":: "
local LOG_FORMAT = "[%s][%s]%s"

local DEBUG_NAME = "DataLink.Debug"

-- // Variables
local Console = { }
local Cache = { }

function Console:CreateMessage(messageType, ...)
	return {
		messageType = messageType,
		message = { ... }
	}
end

function Console:Cache(messageObject)
	if #Cache + 1 >= MAX_CACHE_SIZE then
		table.remove(Cache, #Cache)
	end

	table.insert(Cache, messageObject)
end

function Console:SetLoggingLevel(level)
	self.logLevel = level
end

function Console.init(Datalink)
	Console.Datalink = Datalink
	Console.logLevel = 0

	for _, apiPrototype in {
		{ "Log", 1, print },
		{ "Warn", 2, warn },
		{ "Error", 3, error }
	} do
		Console[apiPrototype[1]] = function(_, ...)
			local messageObject = Console:CreateMessage(apiPrototype[1], ...)
			messageObject.format = string.format(LOG_FORMAT, "DataLink", apiPrototype[1], LOG_PREFIX)

			if Console.logLevel > apiPrototype[2] and not Datalink:GetVariable(DEBUG_NAME) then
				Console:Cache(messageObject)
			else
				apiPrototype[3](messageObject.format, ...)

				Console:Cache(messageObject)
			end
		end
	end
end

return Console