local DateComponent = { }

local function normalizeStandardTime(target)
	local number = tonumber(target)

	if number < 10 then
		return "0" .. target
	else
		return target
	end
end

function DateComponent:from(date)
	return string.format(
		"%s-%s-%sT%s:%s:%s.000Z",
		normalizeStandardTime(date.year),
		normalizeStandardTime(date.month),
		normalizeStandardTime(date.day),
		normalizeStandardTime(date.hour),
		normalizeStandardTime(date.min),
		normalizeStandardTime(date.sec)
	)
end

function DateComponent:fromNow()
	local date = os.date("*t")

	return self:from(date)
end

return DateComponent