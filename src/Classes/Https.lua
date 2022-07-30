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

	body.id = body.id or self.DataLink.internal.id
	body.token = body.token or self.DataLink.internal.token or self.DataLink.internal.key

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
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Status 401, Authenticating")
			self:Authenticate()

			return self:RequestAsync(structType, body, headers)
		end

		self.DataLink.onRequestFailed:Fire(structType, response)
		return false, self.DataLink.internal.Errors.HTTPStatus[response.StatusCode] or response.StatusMessage, response.Headers
	end

	self.DataLink.onRequestSuccess:Fire(structType)
	return true, HttpService:JSONDecode(response.Body), response.Headers
end

function Https:Authenticate()
	local attemptCount = 1

	self.DataLink.internal.token = nil
	self.DataLink.isAuthenticated = false
	self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Authenticating..")
	return self.DataLink.PromiseModule.new(function(promiseObject)
		local success, response = self:RequestAsync(
			self.DataLink.internal.Enums.StructType.Authenticate
		)

		if success then
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Authenticated [" .. response.session_key .. "]")
			self.DataLink.internal.token = response.session_key

			return promiseObject:Resolve()
		else
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Warn, response)

			return promiseObject:Reject(response)
		end
	end):Then(function()
		self.DataLink.isAuthenticated = true
		self.DataLink.onAuthenticated:Fire()
	end):Catch(function(promise)
		self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Attempting to Authenticate [Attempt: " .. attemptCount .. "]")
		attemptCount += 1

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Https.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Https })

	return self
end

return Https