local EndpointType = require(script.Parent.Parent.Enums.EndpointType)

return table.freeze({
	[EndpointType.PublishCustomEvent] = "POST",
	[EndpointType.Update] = "POST",

	[EndpointType.Destroy] = "POST",
	[EndpointType.Heartbeat] = "POST",
	[EndpointType.Authenticate] = "POST",
	[EndpointType.PublishLog] = "POST",
	[EndpointType.FetchLog] = "POST",

	[EndpointType.PlayerJoined] = "POST",
	[EndpointType.PlayerRemoving] = "POST",
	[EndpointType.PlayerTeleporting] = "POST",
	[EndpointType.ServerTerminated] = "POST",
	[EndpointType.FetchFlagInt] = "POST"
})