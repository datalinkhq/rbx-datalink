local DAEMON_SCHEDULER_NAME = "InternalScheduler"

local Sift, Promise

local DaemonComponent
local SchedulerComponent = {
	_taskList = { },
	_processingTasks = false
}

function SchedulerComponent:_createDaemonCallback()
	return function()
		while true do
			self._processingTasks = true

			if #self._taskList <= 0 then
				self._processingTasks = false

				coroutine.yield()

				continue
			end

			self:executeTask(1)
		end
	end
end

function SchedulerComponent:addTaskAsync(callback, priority, taskIndex)
	return Promise.new(function(resolve, reject)
		local internalTaskIndex = (priority and 1) or #self._taskList
		local taskObject = {
			reject = reject,
			resolve = resolve,
			callback = callback,
			index = taskIndex or internalTaskIndex
		}

		self._taskList = Sift.Array.insert(self._taskList, internalTaskIndex, taskObject)

		if not self._processingTasks then
			DaemonComponent:resumeDaemon(DAEMON_SCHEDULER_NAME)
		end
	end)
end

function SchedulerComponent:removeTask(targetTaskIndex)
	for taskIndex in self._taskList do
		local taskObject = self._taskList[taskIndex]

		if taskObject.index ~= targetTaskIndex then
			continue
		end

		table.remove(self._taskList, taskIndex)
	end
end

function SchedulerComponent:executeTask(targetTaskIndex)
	local taskObject = table.remove(self._taskList, targetTaskIndex)
	local taskResolve, taskSuccess = { }, false

	if taskObject.callback then
		taskResolve = { pcall(taskObject.callback) }
		taskSuccess = table.remove(taskResolve, 1)

		if taskObject.resolve and taskSuccess then
			taskObject.resolve(table.unpack(taskResolve))
		elseif taskObject.reject and not taskSuccess then
			taskObject.reject(table.unpack(taskResolve))
		end
	end
end

function SchedulerComponent:start()
	DaemonComponent:addDaemon(self:_createDaemonCallback(), DAEMON_SCHEDULER_NAME, true)
end

function SchedulerComponent:init(SDK)
	Promise = require(SDK.Submodules.Promise)
	Sift = require(SDK.Submodules.Sift)

	DaemonComponent = SDK:_getComponent("DaemonComponent")
end

return SchedulerComponent