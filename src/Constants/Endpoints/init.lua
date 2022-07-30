local Endpoints = { }

Endpoints.Str = "%s%s"
Endpoints.Base = "https://datalink.dev/api"

Endpoints.URLs = { }

for _, Module in script:GetChildren() do
	Endpoints.URLs[Module.Name] = require(Module)
end

return Endpoints