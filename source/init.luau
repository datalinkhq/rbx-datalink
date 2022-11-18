local DatalinkSDK = { }

DatalinkSDK.Data = script.Data
DatalinkSDK.Enums = script.Enums
DatalinkSDK.Submodules = script.Submodules
DatalinkSDK.Components = script.Components
DatalinkSDK.Controllers = script.Controllers

local Sift = require(DatalinkSDK.Submodules.Sift)
local Promise = require(DatalinkSDK.Submodules.Promise)

function DatalinkSDK:getComponent(componentName)
	for _, componentResolve in self._components do
		if componentResolve.name ~= componentName then
			continue
		end

		return componentResolve :: typeof(componentResolve)
	end
end

function DatalinkSDK:invokeEventAsync()
	
end

function DatalinkSDK:getFastIntAsync()
	
end

function DatalinkSDK:getFastFlagAsync()
	
end

function DatalinkSDK:authenticateAsync()
	return Promise.new(function(resolve, reject)
		local HttpComponent = self:getComponent("HttpComponent")
		local SessionController = self:getComponent("SessionController")
		
	end)
end

function DatalinkSDK:getFastFlag()
	
end

function DatalinkSDK.new(datalinkSettings) : typeof(DatalinkSDK)
	local self = setmetatable({
		_settings = datalinkSettings,
		_components = { },
	}, {
		__index = DatalinkSDK
	})

	self._settings = table.freeze(Sift.Dictionary.mergeDeep(self._settings, {
		datalinkUserAccountId = 0,
		datalinkUserToken = ""
	}))

	for _, componentObject in self.Components:GetChildren() do
		local componentResolve = require(componentObject)

		table.insert(self._components, componentResolve)

		if componentResolve.init then
			componentResolve:init(self)
		end
	end

	for _, componentResolve in self._components do
		if componentResolve.start then
			componentResolve:start()
		end
	end

	table.freeze(self._components)

	self._proxy = newproxy(true)
	self._object = self

	getmetatable(self._proxy).__index = function(_, key)
		return self[key]
	end

	return self._proxy :: typeof(self)
end

return DatalinkSDK