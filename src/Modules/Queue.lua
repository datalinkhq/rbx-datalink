--[[
	Queue.lua
]]--

-- // Constants
local YIELDING_COROUTINE_STATUS = "suspended"

-- // Variables
local Queue = { }

function Queue.Pop()
	return table.remove(Queue.list, 1)
end

function Queue.Add(object)
	local thread = coroutine.running()
	table.insert(Queue.list, {
		object, thread
	})

	task.spawn(function()
		while coroutine.status(thread) ~= YIELDING_COROUTINE_STATUS do
			task.wait()
		end

		Queue.Spawn()
	end)

	return coroutine.yield()
end

function Queue.Spawn()
	if Queue.executionYielded or Queue.active then
		return
	end

	task.spawn(Queue.thread)
end

function Queue.Execute()
	local object = Queue.Pop()

	coroutine.resume(object[2], pcall(object[1]))
end

function Queue.init(Datalink)
	Queue.list = { }
	Queue.active = false

	Queue.thread = coroutine.create(function()
		while true do
			Queue.active = true
			while #Queue.list ~= 0 do
				Datalink.Throttle.Increment()
				if Datalink.Throttle.IsThrottled() then
					Datalink.Throttle.reset:Wait()
				end

				Queue.Execute()
			end

			Queue.active = false
			coroutine.yield()
		end
	end)
end

return Queue