--[[

]]--

-- // Variables
local IO = { }

function IO:Write(...)
	-- print(...)
end

function IO.new(DataLink)
	local self = setmetatable({ DataLink = DataLink }, { __index = IO })

	return self
end

return IO