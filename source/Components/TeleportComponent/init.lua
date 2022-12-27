local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

return function(datalinkInstance)
	local PlayerComponent
	local HttpComponent

	local SessionParameters = require(datalinkInstance.Enums.SessionParameters)
	local EndpointType = require(datalinkInstance.Enums.EndpointType)

	local Janitor = require(datalinkInstance.Submodules.Janitor)

	local TeleportComponent = { }

	TeleportComponent.Interface = { }
	TeleportComponent.Internal = { }

	TeleportComponent.TargetState = { }
	TeleportComponent.TeleportState = { }

	function TeleportComponent.Internal:initiateJanitor()
		TeleportComponent.janitor = Janitor.new()

		datalinkInstance._janitor:Add(TeleportComponent.janitor, "Destroy")
	end

	function TeleportComponent.Internal:onPlayerJoined(playerInstance)
		TeleportComponent.janitor:Add(playerInstance.OnTeleport:Connect(function(teleportState, targetPlaceId)
			TeleportComponent.TeleportState[playerInstance] = teleportState
			TeleportComponent.TargetState[playerInstance] = targetPlaceId
		end), nil, playerInstance.UserId)
	end

	function TeleportComponent.Internal:onPlayerLeft(playerInstance)
		local playerTeleportState = TeleportComponent.Interface:getPlayerTeleportState(playerInstance)
		local playerTeleportTarget = TeleportComponent.Interface:getPlayerTeleportTarget(playerInstance)

		if playerTeleportState and playerTeleportState ~= Enum.TeleportState.Failed then
			HttpComponent:requestAsync(EndpointType.PlayerTeleporting, {
				[SessionParameters.AccountId] = PlayerComponent:getPlayerHash(playerInstance),
				[SessionParameters.SessionTime] = PlayerComponent:getPlayerSessionLength(playerInstance),
				[SessionParameters.IsTeleporting] = true,
				[SessionParameters.TeleportPlaceId] = playerTeleportTarget,
			}):andThen(function()
				PlayerComponent:removePlayerData(playerInstance)

				TeleportComponent.TeleportState[playerInstance] = nil
				TeleportComponent.TargetState[playerInstance] = nil

				TeleportComponent.janitor:Remove(playerInstance.UserId)
			end):catch(function()
				task.wait(5)

				TeleportComponent.Internal:onPlayerLeft(playerInstance)
			end)
		end
	end

	function TeleportComponent.Interface:getPlayerTeleportState(player)
		return TeleportComponent.TeleportState[player]
	end

	function TeleportComponent.Interface:getPlayerTeleportTarget(player)
		return TeleportComponent.TargetState[player]
	end

	function TeleportComponent.Interface:start()
		PlayerComponent = datalinkInstance.Internal:getComponent("PlayerComponent")
		HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")

		if not RunService:IsRunning() then
			return
		end

		TeleportComponent.Internal:initiateJanitor()

		for _, playerInstance in Players:GetPlayers() do
			TeleportComponent.Internal:onPlayerJoined(playerInstance)
		end

		datalinkInstance._connections:Add(Players.PlayerAdded:Connect(function(...)
			TeleportComponent.Internal:onPlayerJoined(...)
		end))

		datalinkInstance._connections:Add(Players.PlayerRemoving:Connect(function(...)
			TeleportComponent.Internal:onPlayerLeft(...)
		end))
	end

	return TeleportComponent.Interface
end