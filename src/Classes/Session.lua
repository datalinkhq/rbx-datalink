--[[
	Session.lua

	This modules function is to provide & maintain the DataLink module with it's `Session_Key`
]]--

-- // Constants(
local HEARTBEAT_DELAY_TIME = (1800 / 4)
local INVALID_SESSION_KEY_CONTENT = "Session Key Invalid"

-- // Variables
local Session = { }

function Session:Heartbeat()
	task.wait(HEARTBEAT_DELAY_TIME)

	self.DataLink.PromiseModule.new(function(promiseObject)
		local success, response = self.DataLink.internal.Https:RequestAsync(
			self.DataLink.internal.Enums.StructType.Heartbeat
		)

		if success then
			if response.status == INVALID_SESSION_KEY_CONTENT then
				self.DataLink.internal.Https:Authenticate()
			end

			self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Log, "Heartbeat [", response.status, "]")
			return promiseObject:Resolve()
		else
			return promiseObject:Reject(response)
		end
	end):Then(function()
		self:Heartbeat()
	end):Catch(function(promise, response)
		self.DataLink.internal.IO:Write(self.DataLink.internal.Enums.IOType.Warn, "Heartbeat [", response, "]")

		task.wait(1)
		promise:Retry()
	end)():Await()
end

function Session.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = Session })

	return self
end

return Session