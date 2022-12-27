return function(datalinkInstance)
	local ThrottleLimitType = require(datalinkInstance.Enums.ThrottleLimitType)
	local ThrottleLimits = require(datalinkInstance.Data.ThrottleLimits)

	local ThrottleSignal = datalinkInstance.onThrottled

	local ThrottleComponent = { }

	ThrottleComponent.Interface = { }

	ThrottleComponent.throttleLimit = ThrottleLimits[ThrottleLimitType.GameServerMaxOutboundRequests]
	ThrottleComponent.throttleIndex = 0

	ThrottleComponent.thottleTimestamp = os.clock()
	ThrottleComponent.isThrottled = false

	function ThrottleComponent.Interface:isThrottled()
		return ThrottleComponent.Interface:getThrottleRatio() >= 1
	end

	function ThrottleComponent.Interface:getThrottleRatio()
		return ThrottleComponent.throttleIndex / (ThrottleLimits[ThrottleLimitType.GameServerMaxOutboundRequests] / ThrottleLimits[ThrottleLimitType.GameServerOutboundRequestUsage])
	end

	function ThrottleComponent.Interface:increment()
		ThrottleComponent.throttleIndex += 1

		task.delay(ThrottleLimits[ThrottleLimitType.GameServerThrottleIncrementTimeout], function()
			if ThrottleComponent.throttleIndex - 1 < 0 then
				return
			end

			ThrottleComponent.throttleIndex -= 1
		end)
	end

	function ThrottleComponent.Interface:throttleRequests(seconds)
		local markedTime = os.clock()

		ThrottleComponent.isThrottled = true
		ThrottleComponent.thottleTimestamp = markedTime

		if not seconds then
			return
		end

		ThrottleSignal:Fire(ThrottleComponent.isThrottled)
		task.delay(seconds, function()
			if ThrottleComponent.thottleTimestamp ~= markedTime or not ThrottleComponent.isThrottled then
				return
			end

			ThrottleComponent.isThrottled = false
			ThrottleSignal:Fire(ThrottleComponent.isThrottled)
		end)
	end

	function ThrottleComponent.Interface:setThrottleLimit(limit)
		ThrottleComponent.throttleLimit = limit
		ThrottleComponent.throttleIndex = 0
	end

	return ThrottleComponent.Interface
end