local LogService = game:GetService("LogService")
local PlayersService = game:GetService("Players")

local GameController = { }
local gameProfile = {
	sessionTime = workspace.DistributedGameTime,
	playersJoined = 0
}

function GameController.OnGameLog(logObject)
	-- // TODO: post log profile to API
end

function GameController.OnGameClose()
	-- // TODO: post game profile to API
end

function GameController.OnPlayerAdded(player)
	gameProfile.playersJoined += 1
	gameProfile.sessionTime = workspace.DistributedGameTime
end

function GameController.new(Datalink)
	GameController.Datalink = Datalink

	game:BindToClose(GameController.OnGameClose)

	PlayersService.PlayerAdded:Connect(GameController.OnPlayerAdded)
	LogService.MessageOut:Connect(GameController.OnGameLog)

	for _, object in PlayersService:GetPlayers() do
		GameController.OnPlayerAdded(object)
	end

	for _, object in LogService:GetLogHistory() do
		GameController.OnGameLog(object)
	end
end

return GameController