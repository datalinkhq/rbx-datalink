--[[

]]--

-- // Services
local HttpService = game:GetService("HttpService")

-- // Variables
local Https = { }

function Https:BuildURL(StructType)
	assert(self.DataLink.internal.Endpoint.URLs[StructType], string.format(self.DataLink.internal.Errors.InvalidEndpoint, StructType))

	return string.format(
		self.DataLink.internal.Endpoint.Str,
		self.DataLink.internal.Endpoint.Base,
		string.format(
			self.DataLink.internal.Endpoint.URLs[StructType],
			self.DataLink.internal.id,
			self.DataLink.internal.token
		)
	)
end

function Https:RequestAsync(structType, body, headers)
	local structure = self.DataLink.internal.Struct[structType]
	local url = self:BuildURL(structType)

	local success, response = self.DataLink.internal.Scheduler:JobAsync(function()
		return HttpService:RequestAsync({ Url = url, Method = structure.Method, Headers = headers, Body = body })
	end)

	if not success then
		return success, response, { }
	end

	if not response.Success then
		return false, self.DataLink.internal.Errors.HTTPStatus[response.StatusCode] or response.StatusMessage, response.Headers
	end

	return true, HttpService:JSONDecode(response.Body), response.Headers
end

function Https.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Https })

	return self
end

return Https