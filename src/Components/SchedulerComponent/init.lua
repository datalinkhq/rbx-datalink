local DAEMON_SCHEDULER_NAME = "InternalScheduler"

return function(datalinkInstance)
	local Promise = require(datalinkInstance.Submodules.Promise)
	local Sift = require(datalinkInstance.Submodules.Sift)

	local DaemonComponent = datalinkInstance.Internal:getComponent("DaemonComponent")

	local SchedulerComponent = { }

	SchedulerComponent.ProcessingTasks = false
	SchedulerComponent.TaskList = { }

	SchedulerComponent.Interface = { }
	SchedulerComponent.Internal = { }

	function SchedulerComponent.Internal:createDaemonCallback()
		return function()
			while true do
				SchedulerComponent.ProcessingTasks = true

				if #SchedulerComponent.TaskList <= 0 then
					SchedulerComponent.ProcessingTasks = false

					coroutine.yield()

					continue
				end

				self:executeTask(1)
			end
		end
	end

	function SchedulerComponent.Interface:addTaskAsync(callback, priority, taskIndex)
		return Promise.new(function(resolve, reject)
			local internalTaskIndex = (priority and 1) or #SchedulerComponent.TaskList
			local taskObject = {
				reject = reject,
				resolve = resolve,
				callback = callback,
				index = taskIndex or internalTaskIndex
			}

			SchedulerComponent.TaskList = Sift.Array.insert(SchedulerComponent.TaskList, internalTaskIndex, taskObject)

			if not SchedulerComponent.ProcessingTasks then
				DaemonComponent:resumeDaemon(DAEMON_SCHEDULER_NAME)
			end
		end)
	end

	function SchedulerComponent.Interface:removeTask(targetTaskIndex)
		for taskIndex in SchedulerComponent.TaskList do
			local taskObject = SchedulerComponent.TaskList[taskIndex]

			if taskObject.index ~= targetTaskIndex then
				continue
			end

			table.remove(SchedulerComponent.TaskList, taskIndex)
		end
	end

	function SchedulerComponent.Interface:executeTask(targetTaskIndex)
		local taskObject = table.remove(SchedulerComponent.TaskList, targetTaskIndex)
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

	function SchedulerComponent.Interface:start()
		DaemonComponent:addDaemon(
			SchedulerComponent.Internal:createDaemonCallback(),
			DAEMON_SCHEDULER_NAME,
			true
		)
	end

	return SchedulerComponent.Interface
end