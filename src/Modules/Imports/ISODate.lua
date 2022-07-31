--[[
    ISODate.lua

    @Author: AsynchronousMatrix
    @Licence: ...
]]--


-- // Variables
local ISODate = { }

function ISODate.validate(target)
	local number = tonumber(target)

	if number < 10 then
		return "0" .. target
	else
		return target
	end
end

function ISODate.new()
	local date = os.date("*t")

	return string.format(
		"%s-%s-%sT%s:%s:%s.000Z",
		ISODate.validate(date.year),
		ISODate.validate(date.month),
		ISODate.validate(date.day),
		ISODate.validate(date.hour),
		ISODate.validate(date.min),
		ISODate.validate(date.sec)
	)
end

return ISODate