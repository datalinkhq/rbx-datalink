local LogService = game:GetService("LogService")

local Console = require(script.Parent.Parent.Packages.Console)
local Signal = require(script.Parent.Parent.Packages.Signal)

local MESSAGE_REPORTER_DELAY = 60

local ROBLOX_ERROR_STACK_INFO_PATTERN = "Script '(%S+)', Line (%d+)"
local ROBLOX_ERROR_STACK_BEGIN_PATTERN = "Stack Begin"
local ROBLOX_ERROR_STACK_END_PATTERN = "Stack End"

local LogCaptureService = { }

LogCaptureService.Priority = 0
LogCaptureService.Reporter = Console.new(`🕵️ {script.Name}`)

LogCaptureService.MessageQueue = { }

LogCaptureService.MessageQueueUpdated = Signal.new()

function LogCaptureService.OnMessageOutput(self: LogCaptureService, message: string)
	table.insert(self.MessageQueue, {
		Message = message,
		Type = Enum.MessageType.MessageOutput
	})
end

function LogCaptureService.OnMessageWarning(self: LogCaptureService, message: string)
	table.insert(self.MessageQueue, {
		Message = message,
		Type = Enum.MessageType.MessageWarning
	})
end

function LogCaptureService.OnMessageError(self: LogCaptureService, message: string)
	table.insert(self.MessageQueue, {
		Message = message,
		Type = Enum.MessageType.MessageError
	})
end

function LogCaptureService.OnMessageInfo(self: LogCaptureService, message: string)
	local lastSentMessage = self.MessageQueue[#self.MessageQueue]

	if
		(
			string.match(message, ROBLOX_ERROR_STACK_INFO_PATTERN)
			or string.match(message, ROBLOX_ERROR_STACK_BEGIN_PATTERN)
			or string.match(message, ROBLOX_ERROR_STACK_END_PATTERN)
		) and (
			lastSentMessage and lastSentMessage.Type == Enum.MessageType.MessageError
		)
	then
		lastSentMessage.Message ..= `\n{message}`
	else
		table.insert(self.MessageQueue, {
			Message = message,
			Type = Enum.MessageType.MessageInfo
		})
	end
end

function LogCaptureService.OnStart(self: LogCaptureService)
	LogService.MessageOut:Connect(function(message: string, messageType: Enum.MessageType)
		if messageType == Enum.MessageType.MessageOutput then
			self:OnMessageOutput(message)
		elseif messageType == Enum.MessageType.MessageWarning then
			self:OnMessageWarning(message)
		elseif messageType == Enum.MessageType.MessageError then
			self:OnMessageError(message)
		elseif messageType == Enum.MessageType.MessageInfo then
			self:OnMessageInfo(message)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(MESSAGE_REPORTER_DELAY)

			if #self.MessageQueue == 0 then
				continue
			end

			-- TO-DO: POST message queue to backend.

			self.MessageQueue = { }
		end
	end)
end

export type LogCaptureService = typeof(LogCaptureService)

return LogCaptureService