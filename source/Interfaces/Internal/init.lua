return function(datalinkInstance)
	local Internal = { }

	Internal.Variables = { }
	Internal.Components = { }

	Internal.Interface = { }

	function Internal.Interface:buildDatalinkComponentInstances()
		for _, componentObject in datalinkInstance.Components:GetChildren() do
			local componentResolve = require(componentObject)(datalinkInstance)

			table.insert(Internal.Components, componentResolve)

			if not componentResolve.name then
				componentResolve.name = componentObject.Name
			end
		end
	end

	function Internal.Interface:invokeComponentMethod(method, ...)
		for _, componentResolve in Internal.Components do
			if componentResolve[method] then
				componentResolve[method](componentResolve, ...)
			end
		end
	end

	function Internal.Interface:getComponent(componentName)
		for _, componentResolve in Internal.Components do
			if componentResolve.name ~= componentName then
				continue
			end

			return componentResolve :: typeof(componentResolve)
		end
	end

	function Internal.Interface:setLocalVariable(variableName, variableValue)
		Internal.Variables[variableName] = variableValue
	end

	function Internal.Interface:getLocalVariable(variableName)
		return Internal.Variables[variableName]
	end

	function Internal.Interface:getLocalVariables(...)
		if select("#", ...) == 0 then
			return Internal.Variables
		else
			local datalinkVariables = { }

			for variableIndex, variableName in { ... } do
				datalinkVariables[variableIndex] = self:getLocalVariable(variableName)
			end

			return datalinkVariables
		end
	end

	function Internal.Interface:generateInstanceProxy()
		local proxiedInstance = newproxy(true)
		local proxiedInstanceMetatable = getmetatable(proxiedInstance)

		proxiedInstanceMetatable.__index = function(_, key)
			return datalinkInstance[key]
		end

		proxiedInstanceMetatable.__newindex = function(_, key, value)
			datalinkInstance[key] = value
		end

		return proxiedInstance
	end

	return Internal.Interface
end