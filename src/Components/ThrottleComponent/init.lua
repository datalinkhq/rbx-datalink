local ThrottleComponent = { }

local ThrottleLimitType, ThrottleLimits
local ThrottleSignal

function ThrottleComponent:isThrottled()
	return self:getThrottleRatio() >= 1
end

function ThrottleComponent:getThrottleRatio()
	return self._throttleIndex / (ThrottleLimits[ThrottleLimitType.GameServerMaxOutboundRequests] / ThrottleLimits[ThrottleLimitType.GameServerOutboundRequestUsage])
end

function ThrottleComponent:increment()
	self._throttleIndex += 1

	task.delay(ThrottleLimits[ThrottleLimitType.GameServerThrottleIncrementTimeout], function()
		if self._throttleIndex - 1 < 0 then
			return
		end

		self._throttleIndex -= 1
	end)
end

function ThrottleComponent:throttleRequests(seconds)
	local markedTime = os.clock()

	self._isThrottled = true
	self._throttledTimestamp = markedTime

	if not seconds then
		return
	end

	ThrottleSignal:Fire(self._isThrottled)
	task.delay(seconds, function()
		if self._throttledTimestamp ~= markedTime or not self._isThrottled then
			return
		end

		self._isThrottled = false
		ThrottleSignal:Fire(self._isThrottled)
	end)
end

function ThrottleComponent:setThrottleLimit(limit)
	self._throttleLimit = limit
	self._throttleIndex = 0
end

function ThrottleComponent:init(SDK)
	ThrottleLimitType = require(SDK.Enums.ThrottleLimitType)
	ThrottleLimits = require(SDK.Data.ThrottleLimits)

	ThrottleSignal = SDK.onThrottled

	self:setThrottleLimit(ThrottleLimits[ThrottleLimitType.GameServerMaxOutboundRequests])
end

return ThrottleComponent