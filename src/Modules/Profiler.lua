--[[
	Profiler.lua

	This modules function is to provide the DataLink module with the ability to send/receive data from the DataLink API
]]--

-- // Services
local PlayersService = game:GetService("Players")
local LogService = game:GetService("LogService")
local ScriptContext = game:GetService("ScriptContext")
local LocalizationService = game:GetService("LocalizationService")

-- // Variables
local Profiler = { }
local Players = { }
local GameProfile = { PlayersJoined = 0, GameTime = 0 }
local DropLogRequestKeywords = { "datalink", "promise" }
local MessageTypeChannels = {
	[Enum.MessageType.MessageError] = Enum.AnalyticsLogLevel.Error,
	[Enum.MessageType.MessageWarning] = Enum.AnalyticsLogLevel.Warning,
	[Enum.MessageType.MessageInfo] = Enum.AnalyticsLogLevel.Information,
	[Enum.MessageType.MessageOutput] = Enum.AnalyticsLogLevel.Debug,
}
local IgnoredMessageTypes = {
	[Enum.MessageType.MessageError] = true,
	[Enum.MessageType.MessageInfo] = true,
}

function Profiler.OnPlayerAdded(player)
	local userId, accountAge = player.UserId, player.AccountAge
	local uniqueId = (math.log10(userId) * string.len(userId)) + (math.sqrt(accountAge) - math.log(string.len(userId)))

	local regionSuccess, playerRegion = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, player)
	local friendSuccess, isFriends = pcall(player.IsFriendsWith, player, player.FollowUserId)

	Players[player] = os.clock()

	Profiler.Datalink:FireInternalEvent(Profiler.Datalink.Constants.Enums.Event.PlayerJoined, {
		accountAge = player.AccountAge,
		followedPlayer = player.FollowUserId ~= 0,
		followedFriend = friendSuccess and isFriends,
		premium = player.MembershipType ~= Enum.MembershipType.None,
		locale = player.LocaleId,
		accountId = uniqueId,
		region = (regionSuccess and playerRegion) or "unknown",
	})
end

function Profiler.OnPlayerLeaving(player)
	local userId, accountAge = player.UserId, player.AccountAge
	local uniqueId = (math.log10(userId) * string.len(userId)) + (math.sqrt(accountAge) - math.log(string.len(userId)))

	local timeJoined = Players[player]
	Players[player] = nil

	Profiler.Datalink:FireInternalEvent(Profiler.Datalink.Constants.Enums.Event.PlayerRemoving, {
		accountId = uniqueId,
		sessionTime = os.clock() - timeJoined
	})
end

function Profiler.OnMessageOut(message, messageType)
	for _, keyword in DropLogRequestKeywords do
		if string.find(string.lower(message), keyword) then
			return
		end
	end

	if IgnoredMessageTypes[messageType] then
		return
	end

	Profiler.Datalink:FireLogEvent(MessageTypeChannels[messageType], message, "<unknown>"):Catch(function() end)
end

function Profiler.OnErrorOut(message, stack)
	for _, keyword in DropLogRequestKeywords do
		if string.find(string.lower(stack), keyword) then
			return
		end
	end

	Profiler.Datalink:FireLogEvent(Enum.AnalyticsLogLevel.Error, message, stack):Catch(function() end)
end

function Profiler.OnGameShutdown()
	Profiler.Datalink:FireInternalEvent(
		Profiler.Datalink.Constants.Enums.Event.ServerTerminated,
		GameProfile
	)
end

function Profiler.ForEach(list, callback)
	for _, object in list do
		callback(object)
	end
end

function Profiler.init(Datalink)
	Profiler.Datalink = Datalink

	PlayersService.PlayerAdded:Connect(Profiler.OnPlayerAdded)
	PlayersService.PlayerRemoving:Connect(Profiler.OnPlayerLeaving)

	LogService.MessageOut:Connect(Profiler.OnMessageOut)
	ScriptContext.Error:Connect(Profiler.OnErrorOut)

	Profiler.ForEach(LogService:GetLogHistory(), Profiler.OnMessageOut)
	Profiler.ForEach(PlayersService:GetPlayers(), function(object)
		Profiler.OnPlayerAdded(object)
	end)

	game:BindToClose(function()
		GameProfile.GameTime = workspace.DistributedGameTime

		Profiler.OnGameShutdown()
	end)
end

return Profiler