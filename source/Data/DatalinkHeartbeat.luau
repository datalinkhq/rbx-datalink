local HeartbeatParameter = require(script.Parent.Parent.Enums.HeartbeatParameter)

return table.freeze({
	[HeartbeatParameter.SessionHeartbeatLifetime] = 5, -- 300,
	[HeartbeatParameter.DelayBeforeRetry] = 5,

	[HeartbeatParameter.RetryHeartbeatOnFail] = true
})