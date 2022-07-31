local PlayersService = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local PlayerController = { }
local PlayerProfiles = { }

function PlayerController.Profile(player)
	local success, region = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, player)

	return {
		displayName = player.DisplayName,
		accountAge = player.AccountAge,
		joinedFriend = player.FollowUserId ~= 0,
		premium = player.MembershipType ~= Enum.MembershipType.None,
		locale = player.LocaleId,
		userId = player.UserId,
		region = success and region or "unknown",

		sessionTime = os.time()
	}
end

function PlayerController.OnPlayerAdded(player)
	-- // TODO: post player joined event to API
	PlayerProfiles[player] = PlayerController.Profile(player)
end

function PlayerController.OnPlayerLeaving(player)
	-- // TODO: post player profile to API
	local profileObject = PlayerProfiles[player]

	profileObject.sessionTime = os.time() - profileObject.sessionTime

	print(profileObject)
end

function PlayerController.new(Datalink)
	PlayerController.Datalink = Datalink

	PlayersService.PlayerAdded:Connect(PlayerController.OnPlayerAdded)
	PlayersService.PlayerRemoving:Connect(PlayerController.OnPlayerLeaving)

	for _, object in PlayersService:GetPlayers() do
		PlayerController.OnPlayerAdded(object)
	end
end

return PlayerController