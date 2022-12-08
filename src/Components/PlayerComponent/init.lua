local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")

local CHAT_STRING_VERIFICATION = "42134"
local CHAT_STRING_VALIDATION = "#"

local SessionParameters
local EndpointType

local HttpComponent
local PlayerComponent = {
	_joinClocks = { },
	_sessions = { },
	_hashes = { },

	_sha256 = nil
}

function PlayerComponent:_hashPlayerUserId(playerUserId)
	self._sha256 = self._sha256 or require(script.sha256)

	return self._sha256(tostring(playerUserId))
end

function PlayerComponent:_onPlayerJoined(playerInstance)
	local success0, playerEmailVerified = pcall(MarketplaceService.PlayerOwnsAsset, MarketplaceService, playerInstance, 102611803)
	local success1, playerChatResponse = pcall(Chat.FilterStringForBroadcast, Chat, CHAT_STRING_VERIFICATION, playerInstance)

	self._joinClocks[playerInstance] = os.clock()
	self._hashes[playerInstance] = self:_hashPlayerUserId(playerInstance.UserId)
	self._sessions[self._hashes[playerInstance]] = {
		[SessionParameters.AccountId] = self._hashes[playerInstance],
		[SessionParameters.AcccountAge] = playerInstance.AccountAge,
		[SessionParameters.FollowedPlayer] = playerInstance.FollowUserId ~= 0,
		[SessionParameters.FollowedPlayerId] = playerInstance.FollowUserId ~= 0 and self:_hashPlayerUserId(playerInstance.FollowUserId) or "Unknown",
		[SessionParameters.Premium] = playerInstance.MembershipType ~= Enum.MembershipType.None,
		[SessionParameters.MachineLocale] = playerInstance.LocaleId,
		[SessionParameters.BlueVerified] = playerInstance.HasVerifiedBadge,
		[SessionParameters.Region] = LocalizationService:GetCountryRegionForPlayerAsync(playerInstance),
		[SessionParameters.EmailVerified] = if success0 then playerEmailVerified else "Unknown",
		[SessionParameters.IsUnder13] = if success1 then string.find(playerChatResponse, CHAT_STRING_VALIDATION) == nil else "Unknown"
	}

	HttpComponent:requestAsync(EndpointType.PlayerJoined, self._sessions[self._hashes[playerInstance]])
end

function PlayerComponent:_onPlayerLeft(playerInstance)
	HttpComponent:requestAsync(EndpointType.PlayerRemoving, {
		[SessionParameters.AccountId] = self._hashes[playerInstance],
		[SessionParameters.SessionTime] = os.clock() - self._joinClocks[playerInstance],
	}):andThen(function()
		self._sessions[self._hashes[playerInstance]] = nil
		self._hashes[playerInstance] = nil
		self._joinClocks[playerInstance] = nil
	end):catch(function()
		task.wait(5)

		self:_onPlayerLeft(playerInstance)
	end)
end

function PlayerComponent:getPlayerHash(playerInstance)
	return self._hashes[playerInstance]
end

function PlayerComponent:start(SDK)
	for _, playerInstance in Players:GetPlayers() do
		task.spawn(self._onPlayerJoined, self, playerInstance)
	end

	SDK._connectionsJanitor:Add(Players.PlayerAdded:Connect(function(...)
		self:_onPlayerJoined(...)
	end))

	SDK._connectionsJanitor:Add(Players.PlayerRemoving:Connect(function(...)
		self:_onPlayerLeft(...)
	end))
end

function PlayerComponent:init(SDK)
	SessionParameters = require(SDK.Enums.SessionParameters)
	EndpointType = require(SDK.Enums.EndpointType)

	HttpComponent = SDK:_getComponent("HttpComponent")
end

return PlayerComponent