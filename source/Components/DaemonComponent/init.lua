return function(datalinkInstance)
	local Sift = require(datalinkInstance.Submodules.Sift)

	local DaemonComponent = { }

	DaemonComponent.Daemons = { }
	DaemonComponent.Interface = { }

	function DaemonComponent.Interface:killDaemons()
		for daemonIndex in DaemonComponent.Daemons do
			DaemonComponent.Interface:removeDaemon(daemonIndex)
		end
	end

	function DaemonComponent.Interface:getDeamons()
		return Sift.Dictionary.keys(DaemonComponent.Daemons)
	end

	function DaemonComponent.Interface:removeDaemon(daemonIndex)
		local daemonObject = DaemonComponent.Daemons[daemonIndex]
		if not daemonObject then
			return
		end

		task.cancel(daemonObject._thread)
	end

	function DaemonComponent.Interface:resumeDaemon(daemonIndex, ...)
		local daemonObject = DaemonComponent.Daemons[daemonIndex]
		if not daemonObject then
			return
		end

		task.spawn(daemonObject._thread, ...)
	end

	function DaemonComponent.Interface:addDaemon(daemonCallback, daemonIndex, daemonSerial)
		datalinkInstance.onDaemonInitiated:Fire(daemonIndex)

		DaemonComponent.Daemons[daemonIndex] = {
			_serial = (daemonSerial == true and daemonSerial )or false,
			_thread = task.spawn(function()
				debug.setmemorycategory(daemonIndex)
				if not daemonSerial then
					task.desynchronize()
				end

				daemonCallback()
			end)
		}
	end

	return DaemonComponent.Interface
end