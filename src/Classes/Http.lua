--[[

]]--

-- // Services
local HttpService = game:GetService("HttpService")

-- // Constants

-- // Variables
local Http = { }
local HttpErrors = {
	["Http requests are not enabled. Enable via game settings"] = "HttpDisabled",

	["HTTP 401 (Unauthorized)"] = "HttpUnauthorized",
	["HTTP 400 (Bad Request)"] = "HttpBadRequest"
}

function Http.requestAsync(url, method, headers, body)
	local success, result = pcall(HttpService.RequestAsync, HttpService, { Url = url, Method = method, Headers = headers, Body = body })
	result = (not success and (HttpErrors[result] and Http.DataLink._errorMessages[HttpErrors[result]]) or result) or result

	-- Add `requestAsync` Queue, drop oldest requests if the queue exceeds 100 requests per minute
	-- Add additional support for errors & bad status codes

	return success, result
end

function Http.unitTest()
	local unitUrl = Http.DataLink._builder.build(Http.DataLink._enums.Endpoints.Ping)
	local success, message = pcall(HttpService.GetAsync, HttpService, unitUrl)

	Http.HttpEnabled = success
	if not success then
		Http.HttpError = (HttpErrors[message] and Http.DataLink._errorMessages[HttpErrors[message]]) or message
	else
		Http.UnitResponse = message
	end
end

function Http.new(DataLink)
	Http.DataLink = DataLink
	Http.unitTest()

	return Http
end

return Http