local ThrottleLimitType = require(script.Parent.Parent.Enums.ThrottleLimitType)

return table.freeze({
	[ThrottleLimitType.GameServerMaxOutboundRequests] = 500,
	[ThrottleLimitType.GameServerOutboundRequestUsage] = 0.5,
	[ThrottleLimitType.GameServerThrottleIncrementTimeout] = 60
})