--[[
	Scheduler.lua

	This modules function is to provide a queue & job scheduler for any HTTP requests being sent through the https module
]]--

-- // Constants
local MAX_QUEUE_SIZE = 10
local MAX_WORKERS = 2

local WORKER_IDLE_THREAD = "suspended"

-- // Variables
local Scheduler = { }

function Scheduler:CreateWorker()
	return function()
		while true do
			self.workerCount += 1
			while #self.queue > 0 do
				local jobObject = table.remove(self.queue, 1)

				coroutine.resume(jobObject.thread, pcall(jobObject.callback))
			end

			self.workerCount -= 1
			coroutine.yield()
		end
	end
end

function Scheduler:AssertWorker()
	for _, workerThread in self.workers do
		if coroutine.status(workerThread) == WORKER_IDLE_THREAD then
			return coroutine.resume(workerThread)
		end
	end
end

function Scheduler:AddAsync(object)
	while #self.queue + 1 > MAX_QUEUE_SIZE do
		task.wait()
	end

	table.insert(self.queue, object)
end

function Scheduler:JobAsync(callback)
	self:AddAsync({ callback = callback, thread = coroutine.running() })
	task.delay(0, self.AssertWorker, self)

	return coroutine.yield()
end

function Scheduler.new(DataLink)
	local self = setmetatable({
		DataLink = DataLink,
		queue = { },
		workers = { },
		workerCount = 0
	}, { __index = Scheduler })

	for _ = 1, MAX_WORKERS do
		table.insert(self.workers, coroutine.create(self:CreateWorker()))
	end

	return self
end

return Scheduler