--[[
	Session.lua
]]--

-- // Constants
local HEARTBEAT_DELAY_TIME = 5 -- (1800 / 4)
local INVALID_SESSION_KEY_CONTENT = "Session Key Invalid"

-- // Modules
local Promise = require(script.Parent.Imports.Promise)

-- // Variables
local Session = { }

function Session.Heartbeat()
	task.wait(HEARTBEAT_DELAY_TIME)

	Promise.new(function(promiseObject)
		local success, response = Session.Datalink.Https.RequestAsync(
			Session.Datalink.Constants.Enums.Endpoint.Heartbeat
		)

		if success then
			Session.Datalink.Console:Log("Heartbeat [", response.status, "]")
			if response.status == INVALID_SESSION_KEY_CONTENT then
				Session.Datalink.Https:Authenticate()
			end

			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end):Then(function()
		Session.Heartbeat()
	end):Catch(function(promise, response)
		Session.Datalink.Console:Warn("Heartbeat [", response, "]")

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Session.init(Datalink)
	Session.Datalink = Datalink

	task.spawn(function()
		Session.Heartbeat()
	end)
end

return Session