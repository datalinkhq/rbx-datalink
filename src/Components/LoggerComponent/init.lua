local ScriptContext = game:GetService("ScriptContext")
local LogService = game:GetService("LogService")

local EndpointType
local LogType
local HttpsParameters

local HttpComponent
local LoggerComponent = { }

local logEnumTypes

function LoggerComponent:logMessage(message, ...)
	if not self._getSDKDebugEnabled() then
		return
	end

	self._lastLoggedMessage = message
	print(string.format(message, ...))
end

function LoggerComponent:processMessage(messageType, message, stackTrace)
	if message == self._lastLoggedMessage then
		return
	end

	HttpComponent:requestAsync(EndpointType.PublishLog, {
		[HttpsParameters.Trace] = string.format("%s\n%s", message, stackTrace),
		[HttpsParameters.Type] = messageType
	})
end

function LoggerComponent:start(SDK)
	self._getSDKVerboseLoggingEnabled, self._getSDKDebugEnabled = function()
		return SDK:getLocalVariable("Internal.VerboseLoggingEnabled")
	end, function()
		return SDK:getLocalVariable("Internal.DebugEnabled")
	end

	SDK._connectionsJanitor:Add(LogService.MessageOut:Connect(function(message, messageType)
		if messageType == Enum.MessageType.MessageError or not self._getSDKVerboseLoggingEnabled() then
			return
		end

		self:processMessage(logEnumTypes[messageType], message, "<Stack Trace Not Attached>")
	end))

	SDK._connectionsJanitor:Add(ScriptContext.Error:Connect(function(message, stackTrace)
		self:processMessage(logEnumTypes[Enum.MessageType.MessageError], message, stackTrace)
	end))
end

function LoggerComponent:init(SDK)
	LogType = require(SDK.Enums.LogType)
	EndpointType = require(SDK.Enums.EndpointType)
	HttpsParameters = require(SDK.Enums.HttpsParameters)

	HttpComponent = SDK:_getComponent("HttpComponent")

	logEnumTypes = {
		[Enum.MessageType.MessageOutput] = LogType.Debug,
		[Enum.MessageType.MessageInfo] = LogType.Information,
		[Enum.MessageType.MessageWarning] = LogType.Warning,
		[Enum.MessageType.MessageError] = LogType.Error
		-- [Enum.MessageType.MessageError] = LogType.Fatal
	}
end

return LoggerComponent