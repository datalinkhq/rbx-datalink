local ServerStorage = game:GetService("ServerStorage")
local TestEZ = require(script.TestEZ)

_G.DATALINK_DEVELOPER_ACCOUNT_ID = 3
_G.DATALINK_DEVELOPER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjoiMzhiYzk2ZGYtODQ4Mi00NGFlLTg3MDMtMWNiMGFkZDJiNzk5IiwiaWF0IjoxNjcwMTkzODE3fQ.efzw5tHOZBrTmfJeAjuuhELHI6z2F7GR8w7y8SXB1v8"

TestEZ.TestBootstrap:run({
	ServerStorage.DatalinkSDK.Interfaces,
	ServerStorage.DatalinkSDK.Components
})