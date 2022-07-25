local Enums = { }

for _, Module in script:GetChildren() do
	Enums[Module.Name] = require(Module)
end

return Enums