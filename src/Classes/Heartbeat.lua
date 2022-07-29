--[[
	Heartbeat.lua

	This modules function is to provide & maintain the DataLink module with it's `Session_Key`
]]--

-- // Constants
local HEARTBEAT_DELAY_TIME = 5-- 1800
local INVALID_SESSION_KEY_CONTENT = "Session Key Invalid"

-- // Variables
local Heartbeat = { }

function Heartbeat:Authenticate()
	local attemptCount = 1

	self.DataLink.isAuthenticated = false
	self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Authenticating..")
	return self.DataLink.PromiseModule.new(function(promiseObject)
		local success, response = self.DataLink.internal.Https:RequestAsync(
			self.DataLink.internal.Enums.StructType.Authenticate
		)

		if success then
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Authenticated [" .. response.session_key .. "]")
			self.DataLink.internal.sessionKey = response.session_key

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

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Heartbeat:Heartbeat()
	task.wait(HEARTBEAT_DELAY_TIME)

	self.DataLink.PromiseModule.new(function(promiseObject)
		local success, response = self.DataLink.internal.Https:RequestAsync(
			self.DataLink.internal.Enums.StructType.Heartbeat
		)

		if success then
			if response.StatusMessage == INVALID_SESSION_KEY_CONTENT then
				self:Authenticate()
			end

			return promiseObject:Resolve()
		else
			self:Heartbeat()

			return promiseObject:Reject(response)
		end
	end):Then(function()
		self.DataLink.isAuthenticated = true
		self.DataLink.onAuthenticated:Fire()
	end):Catch(function(promise)
		self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Attempting to Authenticate [Attempt: " .. attemptCount .. "]")

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Heartbeat.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Heartbeat })

	return self
end

return Heartbeat