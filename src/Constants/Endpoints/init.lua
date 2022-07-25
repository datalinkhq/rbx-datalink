local Endpoints = { }

Endpoints.Str = "%s%s"
Endpoints.Base = "https://datalink.vercel.app/api"

Endpoints.URLs = { }

for _, Module in script:GetChildren() do
	Endpoints.URLs[Module.Name] = require(Module)
end

return Endpoints