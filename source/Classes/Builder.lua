--[[

]]--

-- // Modules
local Constants = script.Parent.Parent.Constants
local URLResolves = require(Constants.URLResolves)

-- // Variables
local Builder = { }

function Builder.build(endpoint)
	local id, key = Builder.DataLink._id, Builder.DataLink._key

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