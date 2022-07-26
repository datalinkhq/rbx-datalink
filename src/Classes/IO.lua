--[[

]]--

-- // Constants
local MAX_LOG_CACHE_SIZE = 100

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

	if self.loggingLevel <= logLevel then
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
	self.loggingLevel = level
end

function IO.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = IO })
	self.loggingLevel = 0
	self.logCache = { }
	self.logLevels, self.logTypeCallbacks = {
		[DataLink.internal.Enums.IOType.Log] = 1,
		[DataLink.internal.Enums.IOType.Warn] = 2,
	}, {
		[DataLink.internal.Enums.IOType.Log] = print,
		[DataLink.internal.Enums.IOType.Warn] = warn
	}

	return self
end

return IO