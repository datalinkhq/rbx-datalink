--[[
	IO.lua

	This modules function is to provide the DataLink module a handle to what logs it produces
]]--

-- // Services
local RunService = game:GetService("RunService")

-- // Constants
local MAX_LOG_CACHE_SIZE = 100

local PRODUCTION_LOG_LEVEL = 5
local EDGE_PLACE_ID = 10368553785

-- // Variables
local IO = { }

function IO:Write(logType, ...)
	local logLevel = self.logLevels[logType]

	if #self.logCache + 1 > MAX_LOG_CACHE_SIZE then
		table.remove(self.logCache, 1)
	end

	table.insert(self.logCache, {
		["type"] = logType,
		["args"] = { ... }
	})

	if self.logLevel <= logLevel then
		self.logTypeCallbacks[logType](string.format("[DataLink::%s]: ", logType), ...)
	end
end

function IO:Read(count)
	local cacheResult = { }
	count = math.clamp(count, 0, MAX_LOG_CACHE_SIZE)

	for index = 1, count do
		table.insert(cacheResult, self.logCache[#self.logCache - index])
	end

	return cacheResult
end

function IO:SetLogLevel(level)
	self.logLevel = level
end

function IO.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = IO })
	self.logLevel = 0
	self.logCache = { }
	self.logLevels, self.logTypeCallbacks = {
		[DataLink.internal.Enums.IOType.Log] = 1,
		[DataLink.internal.Enums.IOType.Warn] = 2,
	}, {
		[DataLink.internal.Enums.IOType.Log] = print,
		[DataLink.internal.Enums.IOType.Warn] = warn
	}

	if game.PlaceId ~= EDGE_PLACE_ID or not RunService:IsStudio() then
		self:SetLogLevel(PRODUCTION_LOG_LEVEL)
		self:Write(DataLink.internal.Enums.IOType.Log, string.format("SetLogLevel %d -> %d [Unknown Environ]", self.logLevel, PRODUCTION_LOG_LEVEL))
	end

	return self
end

return IO