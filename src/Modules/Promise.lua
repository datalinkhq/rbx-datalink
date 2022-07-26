--[[
    Promise.lua

    @Author: AsynchronousMatrix
    @Licence: ...
]]--

-- // Variables
local PromiseModule = { }
local PromiseObject = { Name = "Promise" }

PromiseObject.__index = PromiseObject
PromiseObject.__call = function(self, ...)
	if self.Rejected or self.Resolved then 
		return unpack(self.Result) 
	end

	self.Args = { ... }

	local Thread = coroutine.create(self._Function)
	local Success, Result = coroutine.resume(Thread, self, ...)

	if not Success then
		self:Reject(Result)
	end

	return self
end

-- // PromiseObject Functions
function PromiseObject:Get()
	if self.Rejected or self.Resolved then 
		return unpack(self.Result) 
	end
end

function PromiseObject:Finally(Callback)
	self._FinallyCallback = Callback

	if self.Rejected or self.Resolved then 
		self._Cancel = true

		Callback(self, unpack(self.Result))
	end

	return self
end

function PromiseObject:Catch(Callback)
	self._CatchCallback = Callback

	if self.Rejected then 
		Callback(self, unpack(self.Result))
	end

	return self
end

function PromiseObject:Then(Callback)
	table.insert(self._Stack, Callback)

	if self.Rejected or self.Resolved then 
		Callback(self, unpack(self.Result))
	end

	return self
end

function PromiseObject:Cancel()
	self._Cancel = true
end

function PromiseObject:Retry()
	self.Rejected = nil
	self.Resolved = nil
	self._Cancel = nil
	
	return (self.Args and self(unpack(self.Args))) or self()
end

function PromiseObject:Await()
	if self.Rejected or self.Resolved then 
		return self
	else
		table.insert(self._Await, coroutine.running())

		return coroutine.yield()
	end
end

function PromiseObject:Resolve(...)
	if self.Rejected or self.Resolved then 
		return
	end

	self.Resolved = true
	self.Result = { ... }

	for _, Thread in ipairs(self._Await) do
		coroutine.resume(Thread, self, ...)
	end

	for _, Callback in ipairs(self._Stack) do
		Callback(self, ...)

		if self._Cancel then
			self._Cancel = nil

			break
		end
	end

	if self._FinallyCallback then
		self._FinallyCallback(self, ...)
	end

	self._Await = { }
end

function PromiseObject:Reject(...)
	if self.Rejected or self.Resolved then 
		return
	end

	self.Rejected = true
	self.Result = { ... }

	for _, Thread in ipairs(self._Await) do
		coroutine.resume(Thread, self, ...)
	end

	if self._CatchCallback then
		self._CatchCallback(self, ...)
	else
		print(string.format("Unhandled Promise Rejection: [ %s ]", table.concat(self.Result, ", ")))
	end
end

-- // PromiseModule Functions
function PromiseModule.new(Function)
	return setmetatable({ _Function = Function, _Stack = { }, _Await = { } }, PromiseObject)
end

function PromiseModule.Wrap(Function, ...)
	return PromiseModule.new(function(Promise, ...)
		local Result = { pcall(Function, ...) }

		return (table.remove(Result, 1) and Promise:Resolve(unpack(Result))) or Promise:Reject(unpack(Result))
	end, ...)
end

function PromiseModule.Settle(Promises)
	for _, Promise in ipairs(Promises) do
		Promise:Await()
	end
end

function PromiseModule.AwaitSuccess(Promise)
	repeat Promise:Await() until Promise.Resolved

	return Promise:Get()
end

-- // Module
return PromiseModule