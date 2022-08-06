--[[
	deviceType.lua
]]--

-- // Services
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- // Constants
local ANALYTICS_RECEIVER_REMOTE_NAME = "AnalyticsReceiver"
local MAX_PHONE_SCREEN_SIZE_Y = 600

-- // Variables
local remoteObject = script:WaitForChild(ANALYTICS_RECEIVER_REMOTE_NAME)
local deviceType = ""

if GuiService:IsTenFootInterface() or UserInputService.GamepadEnabled then
	deviceType = "Console"
elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
	local deviceSize = workspace.CurrentCamera.ViewportSize

	if deviceSize.Y > MAX_PHONE_SCREEN_SIZE_Y then
		deviceType = "Tablet"
	else
		deviceType = "Phone"
	end
elseif UserInputService.VREnabled then
	deviceType = "VR"
else
	deviceType = "Computer"
end

remoteObject:FireServer(deviceType)