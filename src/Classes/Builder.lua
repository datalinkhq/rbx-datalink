--[[

]]--

-- // Services
local HttpService = game:GetService("HttpService")

-- // Modules
local Constants = script.Parent.Parent.Constants
local URLResolves = require(Constants.URLResolves)

-- // Variables
local Builder = { }

function Builder.packet(...)
	return HttpService:JSONEncode({ ...})
end

function Builder.build(endpoint)
	local id, key = Builder.DataLink._id, Builder.DataLink._key
	assert(URLResolves.Endpoints[endpoint], string.format(Builder.DataLink._errorMessages["InvalidEndpoint"], endpoint))

	return string.format(
		URLResolves.Struct,
		URLResolves.URL,
		URLResolves.Endpoints[endpoint],
		id, key
	)
end

function Builder.new(DataLink)
	Builder.DataLink = DataLink

	return Builder
end

return Builder