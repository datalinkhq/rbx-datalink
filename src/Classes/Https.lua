--[[
	Https.lua

	This modules function is to provide the DataLink module with the ability to send/receive data from the DataLink API
]]--

-- // Services
local HttpService = game:GetService("HttpService")

-- // Constants
local INVALID_SESSION_KEY_CONTENT = "Unauthorized"

-- // Variables
local Https = { }

function Https:BuildURL(structType)
	assert(self.DataLink.internal.Endpoint.URLs[structType], string.format(self.DataLink.internal.Errors.InvalidEndpoint, structType))

	return string.format(
		self.DataLink.internal.Endpoint.Str,
		self.DataLink.internal.Endpoint.Base,
		string.format(
			self.DataLink.internal.Endpoint.URLs[structType],
			self.DataLink.internal.id,
			self.DataLink.internal.token
		)
	)
end

function Https:BuildHeaders(headers)
	headers = headers or { }

	headers["Content-Type"] = "application/json"

	return headers
end

function Https:BuildBody(body)
	body = body or { }

	body.id = self.DataLink.internal.id
	body.token = self.DataLink.internal.token
	body.session_key = self.DataLink.internal.sessionKey

	return HttpService:JSONEncode(body)
end

function Https:RequestAsync(structType, body, headers)
	local structure = self.DataLink.internal.Struct[structType]
	local url = self:BuildURL(structType)

	local success, response = self.DataLink.internal.Scheduler:JobAsync(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = structure.Method,
			Headers = self:BuildHeaders(headers),
			Body = self:BuildBody(body)
		})
	end)

	if not success then
		self.DataLink.onRequestFailed:Fire(structType, response)

		return success, response, { }
	end

	if not response.Success then
		if response.StatusCode == 401 and response.StatusMessage == INVALID_SESSION_KEY_CONTENT then
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Status 401, Invoking Heartbeat")
			self.DataLink.internal.Heartbeat:Authenticate()

			return self:RequestAsync(structType, body, headers)
		end

		self.DataLink.onRequestFailed:Fire(structType, response)
		return false, self.DataLink.internal.Errors.HTTPStatus[response.StatusCode] or response.StatusMessage, response.Headers
	end

	self.DataLink.onRequestSuccess:Fire(structType)
	return true, HttpService:JSONDecode(response.Body), response.Headers
end

function Https.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Https })

	return self
end

return Https