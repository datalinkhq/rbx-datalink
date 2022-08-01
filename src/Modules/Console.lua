--[[
	Console.lua

	This modules function is to provide the DataLink module a handle to what logs it produces
]]--

-- // Services
local RunService = game:GetService("RunService")

-- // Constants
local MAX_LOG_CACHE_SIZE = 100

local PRODUCTION_LOG_LEVEL = 5
local EDGE_PLACE_ID = 10368553785

-- // Variables
local Console = { }

function Console:Log(...)
	if Console.logLevel > 1 then
		return
	end

	print("[Datalink][Log]::", ...)
end

function Console:Warn(...)
	if Console.logLevel > 2 then
		return
	end

	warn("[Datalink][Warn]::", ...)
end

function Console.init(Datalink)
	Console.logLevel = 0

	Console.Datalink = Datalink
end

return Console