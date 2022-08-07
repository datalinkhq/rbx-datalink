--[[
	Https.lua

	This modules function is to provide the DataLink module with the ability to send/receive data from the DataLink API
]]--

-- // Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- // Constants
local INVALID_SESSION_KEY_CONTENT = "Unauthorized"
local HTTP_CONTENT_TYPE = "application/json"

-- // Modules
local Promise = require(script.Parent.Imports.Promise)

-- // Variables
local Https = { }

function Https.ResolveUrl(endpoint)
	assert(Https.Datalink.Constants.Endpoints[endpoint], string.format(Https.Datalink.Constants.Errors.InvalidEndpoint, endpoint))

	return string.format(
		Https.Datalink.Constants.Model,
		Https.Datalink.Constants.Api,
		Https.Datalink.Constants.Endpoints[endpoint][1]
	), Https.Datalink.Constants.Endpoints[endpoint][2]
end

function Https.AssertHeaders(headers)
	headers = headers or { }

	headers["Content-Type"] = HTTP_CONTENT_TYPE

	return headers
end

function Https.AssertBody(body)
	body = body or { }

	body.id = body.id or Https.Datalink.developerId

	if Https.Datalink.isAuthenticated and Https.Datalink.sessionKey then
		body.token = body.token or Https.Datalink.sessionKey
	else
		body.token = body.token or Https.Datalink.developerKey
	end

	return HttpService:JSONEncode(body)
end

function Https.RequestAsync(endpoint, body, headers)
	local success, response = Https.Datalink.Queue.Add(function()
		local resolvedUrl, urlMethod = Https.ResolveUrl(endpoint)

		print({
			Url = resolvedUrl,
			Method = urlMethod,

			Headers = Https.AssertHeaders(headers),
			Body = Https.AssertBody(body)
		})

		return HttpService:RequestAsync({
			Url = resolvedUrl,
			Method = urlMethod,

			Headers = Https.AssertHeaders(headers),
			Body = Https.AssertBody(body)
		})
	end)

	if not success then
		Https.Datalink.onRequestFailed:Fire(endpoint, response)

		return success, response, { }
	end

	if not response.Success then
		if response.StatusCode == 401 and response.StatusMessage == INVALID_SESSION_KEY_CONTENT then
			Https.Datalink.Console:Log("Status 401, Authenticating")
			Https.Authenticate()

			return Https.RequestAsync(endpoint, body, headers)
		end

		Https.Datalink.onRequestFailed:Fire(endpoint, response)
		return false, Https.Datalink.Constants.Errors.HTTPStatus[response.StatusCode] or response.StatusMessage, response.Headers
	end

	Https.Datalink.onRequestSuccess:Fire(endpoint)
	return true, HttpService:JSONDecode(response.Body), response.Headers
end

function Https.Authenticate()
	if Https.Datalink.isAuthenticating then
		return
	end

	local attemptCount = 1

	Https.Datalink.isAuthenticated = false
	Https.Datalink.isAuthenticating = true
	Https.Datalink.Console:Log("Authenticating..")
	return Promise.new(function(promiseObject)
		local success, response = pcall(function()
			local resolvedUrl, urlMethod = Https.ResolveUrl(Https.Datalink.Constants.Enums.Endpoint.Authenticate)

			return HttpService:RequestAsync({
				Url = resolvedUrl,
				Method = urlMethod,

				Headers = Https.AssertHeaders(),
				Body = Https.AssertBody({
					isStudio = RunService:IsStudio()
				})
			})
		end)

		if success and response.StatusCode == 200 then
			local body = HttpService:JSONDecode(response.Body)

			Https.Datalink.Console:Log("Authenticated [" .. body.session_key .. "]")
			Https.Datalink.sessionKey = body.session_key

			return promiseObject:Resolve()
		else
			Https.Datalink.Console:Warn((type(response) == "string" and response) or response.StatusMessage)

			return promiseObject:Reject(response)
		end
	end):Then(function()
		Https.Datalink.isAuthenticated = true
		Https.Datalink.isAuthenticating = false
		Https.Datalink.onAuthenticated:Fire()
	end):Catch(function(promise)
		Https.Datalink.Console:Log("Attempting to Authenticate [Attempt: " .. attemptCount .. "]")
		attemptCount += 1

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Https.init(Datalink)
	Https.Datalink = Datalink
end

return Https