--[[
	Controller.lua
]]--

-- // Constants
local FETCHER_CONTAINER_TIMEOUT = 5

-- // Variables
local ClientController = { }

local feviceDeviceTypeContainer = script.Fetchers.deviceType

function ClientController.DeployFetcherContainer(player, targetFetcherContainer, listener)
	local container = targetFetcherContainer:Clone()
	local remoteObject = Instance.new("RemoteEvent")
	local remoteConnection

	remoteObject.Parent = container
	remoteObject.Name = "AnalyticsReceiver"

	remoteConnection = remoteObject.OnServerEvent:Connect(function(invokedPlayer, ...)
		if invokedPlayer ~= player then
			return
		end

		remoteConnection:Disconnect()

		remoteObject:Destroy()
		container:Destroy()

		listener(true, ...)
	end)

	container.Parent = player:WaitForChild("PlayerGui")

	task.delay(FETCHER_CONTAINER_TIMEOUT, function()
		if not remoteConnection.Connected then
			return
		end

		remoteConnection:Disconnect()

		remoteObject:Destroy()
		container:Destroy()

		listener(false)
	end)
end

function ClientController.FetchDeviceType(player)
	local thread = coroutine.running()
	ClientController.DeployFetcherContainer(player, feviceDeviceTypeContainer, function(success, deviceType)
		coroutine.resume(thread, (success and deviceType) or "<unknown>")
	end)

	return coroutine.yield()
end

function ClientController.init(datalink)
	ClientController.Datalink = datalink
end

return ClientController