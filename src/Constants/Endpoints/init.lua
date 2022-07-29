local Endpoints = { }

Endpoints.Str = "%s%s"
Endpoints.Base = "http://localhost:3000/api"

Endpoints.URLs = { }

for _, Module in script:GetChildren() do
	Endpoints.URLs[Module.Name] = require(Module)
end

return Endpoints