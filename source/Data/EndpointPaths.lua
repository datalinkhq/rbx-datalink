local EndpointType = require(script.Parent.Parent.Enums.EndpointType)

return table.freeze({
	[EndpointType.PublishCustomEvent] = "/events/publish",
	[EndpointType.Update] = "/events/update",

	[EndpointType.Destroy] = "/destroy",
	[EndpointType.Heartbeat] = "/heartbeat",
	[EndpointType.Authenticate] = "/auth",
	[EndpointType.PublishLog] = "/logs/publish",
	[EndpointType.FetchLog] = "/logs/fetch",

	[EndpointType.PlayerTeleporting] = "/internal/playerTeleported",
	[EndpointType.PlayerJoined] = "/internal/playerJoined",
	[EndpointType.PlayerRemoving] = "/internal/playerLeft",
	[EndpointType.FetchFlagInt] = "/ff/fetch"
})