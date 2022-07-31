local PlayersService = game:GetService("Players")

local ClientController = { }
local ClientDatalink = script.Datalink

function ClientController.OnPlayerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")

	ClientDatalink:Clone().Parent = playerGui
end

function ClientController.new(Datalink)
	ClientController.Datalink = Datalink

	PlayersService.PlayerAdded:Connect(ClientController.OnPlayerAdded)

	for _, object in PlayersService:GetPlayers() do
		ClientController.OnPlayerAdded(object)
	end
end

return ClientController