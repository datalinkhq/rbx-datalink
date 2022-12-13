local Sift

local DaemonInitiatedSignal
local DaemonComponent = {
	_daemons = { }
}

function DaemonComponent:killDaemons()
	for daemonIndex in self._daemons do
		self:removeDaemon(daemonIndex)
	end
end

function DaemonComponent:getDeamons()
	return Sift.Dictionary.keys(self._daemons)
end

function DaemonComponent:removeDaemon(daemonIndex)
	local daemonObject = self._daemons[daemonIndex]
	if not daemonObject then
		return
	end

	task.cancel(daemonObject._thread)
end

function DaemonComponent:resumeDaemon(daemonIndex, ...)
	local daemonObject = self._daemons[daemonIndex]
	if not daemonObject then
		return
	end

	task.spawn(daemonObject._thread, ...)
end

function DaemonComponent:addDaemon(daemonCallback, daemonIndex, daemonSerial)
	DaemonInitiatedSignal:Fire(daemonIndex)

	self._daemons[daemonIndex] = {
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

function DaemonComponent:init(SDK)
	Sift = require(SDK.Submodules.Sift)

	DaemonInitiatedSignal = SDK.onDaemonInitiated
end

return DaemonComponent