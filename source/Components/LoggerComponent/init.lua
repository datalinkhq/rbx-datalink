local ScriptContext = game:GetService("ScriptContext")
local LogService = game:GetService("LogService")

return function(datalinkInstance)
	local HttpComponent

	local LogType = require(datalinkInstance.Enums.LogType)
	local EndpointType = require(datalinkInstance.Enums.EndpointType)
	local HttpsParameters = require(datalinkInstance.Enums.HttpsParameters)

	local LoggerComponent = { }

	LoggerComponent.Interface = { }
	LoggerComponent.Internal = { }

	LoggerComponent.EnumerationTypes = {
		[Enum.MessageType.MessageOutput] = LogType.Debug,
		[Enum.MessageType.MessageInfo] = LogType.Information,
		[Enum.MessageType.MessageWarning] = LogType.Warning,
		[Enum.MessageType.MessageError] = LogType.Error
	}

	function LoggerComponent.Internal:processMessage(messageType, message, stackTrace)
		if not datalinkInstance.Internal:getLocalVariable("Internal.VerboseLoggingEnabled") then
			stackTrace = "<Verbose Logging Disabled>"
		end

		-- HttpComponent:requestAsync(EndpointType.PublishLog, {
		-- 	[HttpsParameters.Trace] = string.format("%s\n%s", message, stackTrace),
		-- 	[HttpsParameters.Type] = messageType
		-- })
	end

	function LoggerComponent.Interface:start()
		HttpComponent = datalinkInstance.Internal:getComponent("HttpComponent")

		datalinkInstance._connections:Add(LogService.MessageOut:Connect(function(message, messageType)
			if messageType == Enum.MessageType.MessageError then
				return
			end

			LoggerComponent.Internal:processMessage(LoggerComponent.EnumerationTypes[messageType], message, "<Stack Trace Not Attached>")
		end))

		datalinkInstance._connections:Add(ScriptContext.Error:Connect(function(message, stackTrace)
			LoggerComponent.Internal:processMessage(LoggerComponent.EnumerationTypes[Enum.MessageType.MessageError], message, stackTrace)
		end))
	end

	return LoggerComponent.Interface
end