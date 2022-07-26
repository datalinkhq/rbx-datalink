--[[

]]--

-- // Constants
local HEARTBEAT_DELAY_TIME = 1800

-- // Variables
local Heartbeat = { }

function Heartbeat:Authenticate()
	self.DataLink.isAuthenticated = false
	return self.DataLink.PromiseModule.new(function(promiseObject)
		local success, response = self.DataLink.internal.Https:RequestAsync(
			self.DataLink.internal.Enums.StructType.Authenticate
		)

		if success then
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Authenticated, SessionKey: " .. response.session_key)
			self.DataLink.internal.sessionKey = response.session_key

			return promiseObject:Resolve()
		else
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Warn, response)

			return promiseObject:Reject(response)
		end
	end):Then(function()
		self.DataLink.isAuthenticated = true
		self.DataLink.onAuthenticated:Fire()
	end)():Await()
end

function Heartbeat:Deauthenticate()
	if self.DataLink.internal.sessionKey then
		local success, response = self.DataLink.internal.Https:RequestAsync(
			self.DataLink.internal.Enums.StructType.Destroy
		)

		if success then
			self.DataLink.internal.sessionKey = nil
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "De-Authenticated")
		else
			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Warn, response)
		end
	end
end

function Heartbeat:Heartbeat()
	self:Deauthenticate()
	self:Authenticate()

	self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Sent Heartbeat")
	task.delay(HEARTBEAT_DELAY_TIME, self.Heartbeat, self)
end

function Heartbeat.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Heartbeat })
	game:BindToClose(function()
		self:Deauthenticate()
	end)

	return self
end

return Heartbeat