local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

local CHAT_STRING_VERIFICATION = "42134"
local CHAT_STRING_VALIDATION = "#"

local EMAIL_VERIFIED_ASSET_ID = 102611803

return function(datalinkInstance)
	local TeleportComponent
	local HttpComponent
	local Sha256Component

	local SessionParameters = require(datalinkInstance.Enums.SessionParameters)
	local EndpointType = require(datalinkInstance.Enums.EndpointType)

	local PlayerComponent = { }

	PlayerComponent.TeleportStates = { }
	PlayerComponent.PlayerClocks = { }
	PlayerComponent.PlayerSessions = { }
	PlayerComponent.PlayerHashes = { }

	PlayerComponent.Internal = { }
	PlayerComponent.Interface = { }

	function PlayerComponent.Internal:onPlayerJoined(playerInstance)
		local success0, playerEmailVerified = pcall(MarketplaceService.PlayerOwnsAsset, MarketplaceService, playerInstance, EMAIL_VERIFIED_ASSET_ID)
		local success1, playerChatResponse = pcall(Chat.FilterStringForBroadcast, Chat, CHAT_STRING_VERIFICATION, playerInstance)

		PlayerComponent.PlayerClocks[playerInstance] = os.clock()
		PlayerComponent.PlayerHashes[playerInstance] = Sha256Component:hash(tostring(playerInstance.UserId))
		PlayerComponent.PlayerSessions[PlayerComponent.PlayerHashes[playerInstance]] = {
			[SessionParameters.AccountId] = PlayerComponent.PlayerHashes[playerInstance],
			[SessionParameters.AcccountAge] = playerInstance.AccountAge,
			[SessionParameters.FollowedPlayer] = playerInstance.FollowUserId ~= 0,
			[SessionParameters.FollowedPlayerId] = playerInstance.FollowUserId ~= 0 and  Sha256Component:hash(tostring(playerInstance.FollowUserId)) or "Unknown",
			[SessionParameters.Premium] = playerInstance.MembershipType ~= Enum.MembershipType.None,
			[SessionParameters.MachineLocale] = playerInstance.LocaleId,
			[SessionParameters.BlueVerified] = playerInstance.HasVerifiedBadge,
			[SessionParameters.Region] = LocalizationService:GetCountryRegionForPlayerAsync(playerInstance),
			[SessionParameters.EmailVerified] = if success0 then playerEmailVerified else "Unknown",
			[SessionParameters.IsUnder13] = if success1 then string.find(playerChatResponse, CHAT_STRING_VALIDATION) == nil else "Unknown"
		}

		HttpComponent:requestAsync(EndpointType.PlayerJoined, PlayerComponent.PlayerSessions[PlayerComponent.PlayerHashes[playerInstance]])
	end

	function PlayerComponent.Internal:onPlayerLeft(playerInstance)
		if TeleportComponent:getPlayerTeleportState(playerInstance) then
			return
		end

		HttpComponent:requestAsync(EndpointType.PlayerRemoving, {
			[SessionParameters.AccountId] = PlayerComponent.Interface:getPlayerHash(playerInstance),
			[SessionParameters.SessionTime] = PlayerComponent.Interface:getPlayerSessionLength(playerInstance),
			[SessionParameters.IsTeleporting] = false,
		}):andThen(function()
			PlayerComponent.Interface:removePlayerData(playerInstance)
		end):catch(function()
			task.wait(5)

			PlayerComponent.Internal:onPlayerLeft(playerInstance)
		end)
	end

	function PlayerComponent.Interface:getPlayerSessionLength(playerInstance)
		return os.clock() - PlayerComponent.PlayerClocks[playerInstance]
	end

	function PlayerComponent.Interface:getPlayerHash(playerInstance)
		return PlayerComponent.PlayerHashes[playerInstance]
	end

	function PlayerComponent.Interface:removePlayerData(player)
		PlayerComponent.PlayerSessions[PlayerComponent.PlayerHashes[player]] = nil
		PlayerComponent.PlayerHashes[player] = nil
		PlayerComponent.PlayerClocks[player] = nil
	end

	function PlayerComponent.Interface:start()
		TeleportComponent = datalinkInstance.Internal:getComponent("TeleportComponent")
		HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")
		Sha256Component = datalinkInstance.Internal:getComponent("Sha256Component")

		if not RunService:IsRunning() then
			return
		end

		for _, playerInstance in Players:GetPlayers() do
			task.defer(function()
				PlayerComponent.Internal:onPlayerJoined(playerInstance)
			end)
		end

		datalinkInstance._connections:Add(Players.PlayerAdded:Connect(function(...)
			PlayerComponent.Internal:onPlayerJoined(...)
		end))

		datalinkInstance._connections:Add(Players.PlayerRemoving:Connect(function(...)
			PlayerComponent.Internal:onPlayerLeft(...)
		end))
	end

	return PlayerComponent.Interface
end