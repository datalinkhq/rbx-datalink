local ServerStorage = game:GetService("ServerStorage")

if not ServerStorage:FindFirstChild("Secrets") then
	return error("Failed to execute 'Datalink SDK' tests: Invalid 'Secrets' module under 'ServerStorage'")
end

local Secrets = require(ServerStorage.Secrets)
local TestEZ = require(script.TestEZ)

_G.DATALINK_DEVELOPER_ACCOUNT_ID = Secrets.DATALINK_DEVELOPER_ACCOUNT_ID
_G.DATALINK_DEVELOPER_TOKEN = Secrets.DATALINK_DEVELOPER_TOKEN

TestEZ.TestBootstrap:run({
	ServerStorage.DatalinkSDK.Interfaces,
	ServerStorage.DatalinkSDK.Components
})