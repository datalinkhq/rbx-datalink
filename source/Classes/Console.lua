--[[

]]--

-- // Variables
local Console = { }

function Console:log(...)
	if not Console.DataLink._debugEnabled then
		return
	end

	print("[DataLink] ::", ...)
end

function Console.new(DataLink)
	Console.DataLink = DataLink

	return Console
end

return Console