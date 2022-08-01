return table.freeze({
	Model = "%s%s",
	Api = "https://datalink.dev/api",

	Endpoints = {
		Publish = { "/events/publish", "POST" },
		Update = { "/events/update", "POST" },

		Destroy = { "/destroy", "POST" },
		Heartbeat = { "/heartbeat", "POST" },
		Authenticate = { "/auth", "POST" },
		Log = { "/logs/publish", "POST" }
	},

	Enums = {
		Endpoint = {
			Publish = "Publish",
			Update = "Update",
			Log = "Log",

			Destroy = "Destroy",
			Heartbeat = "Heartbeat",
			Authenticate = "Authenticate",
		},

		Event = {
			"PlayerJoined",
			"PlayerRemoving",
			"ServerTerminated"
		}
	},

	Errors = {
		Initialized = "DataLink Analytics is already initialized",

		InvalidId = "Invalid Authenticator Id",
		InvalidKey = "Invalid Authenticator Key",
		InvalidEndpoint = "Invalid Endpoint '%s'",

		HTTPStatus = {
			[401] = "Invalid ID/Token, Unauthenticated",
		}
	},
})