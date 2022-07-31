--[[
    Signal.lua

    @Author: AsynchronousMatrix
    @Licence: ...
]]--

-- // Variables
local SignalModule = { Simple = { } }
local SignalObject = { Name = "Mutex" }
local ConnectionObject = { Name = "Connection" }

SignalObject.__index = SignalObject
ConnectionObject.__index = ConnectionObject

-- // ConnectionObject Functions
function ConnectionObject:Reconnect()
    if self.Connected then return end

    self.Connected = true
    self._Connect()
end

function ConnectionObject:Disconnect()
    if not self.Connected then return end

    self.Connected = false
    self._Disconnect()
end

-- // SignalObject Functions
function SignalObject:Wait()
    local Coroutine = coroutine.running()

    table.insert(self._Yield, Coroutine)
    return coroutine.yield()
end

function SignalObject:Connect(Callback)
    local Connection = SignalModule.newConnection(function()
        table.insert(self._Tasks, Callback)
    end, function()
        for Index, TaskCallback in ipairs(self._Tasks) do
            if TaskCallback == Callback then
               return table.remove(self._Tasks, Index)
            end
        end
    end)

    Connection:Reconnect()
    return Connection
end

function SignalObject:Fire(...)
    for _, TaskCallback in ipairs(self._Tasks) do
        local Callback = TaskCallback

        if self.UseCoroutines then
            Callback = coroutine.wrap(Callback)
        end

        task.spawn(Callback, ...)
    end

    for _, YieldCoroutine in ipairs(self._Yield) do
        coroutine.resume(YieldCoroutine, ...)
    end

    self._Yield = { }
end

-- // SignalModule Functions
function SignalModule.newConnection(ConnectCallback, disconnectCallback)
    return setmetatable({ 
        _Connect = ConnectCallback, 
        _Disconnect = disconnectCallback, 
        Connected = false
    }, ConnectionObject)
end

function SignalModule.new()
	local self = setmetatable({ 
        _Tasks = { }, _Yield = { },
        UseCoroutines = false
    }, SignalObject)

	return self
end

-- // Module
return SignalModule