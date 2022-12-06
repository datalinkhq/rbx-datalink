local EndpointType = require(script.Parent.Parent.Enums.EndpointType)

return table.freeze({
	[EndpointType.PublishCustomEvent] = "/events/publish",
	[EndpointType.Update] = "/events/update",

	[EndpointType.Destroy] = "/destroy",
	[EndpointType.Heartbeat] = "/heartbeat",
	[EndpointType.Authenticate] = "/auth",
	[EndpointType.Log] = "/logs/publish",

	[EndpointType.PlayerJoined] = "/internal/playerJoined",
	[EndpointType.PlayerRemoving] = "/internal/playerLeft",
	[EndpointType.ServerTerminated] = "/internal/serverTerminated",
	[EndpointType.FetchFlagInt] = "/ff/fetch"
})