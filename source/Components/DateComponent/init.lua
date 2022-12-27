return function()
	local DateComponent = { }

	DateComponent.Interface = { }
	DateComponent.Internal = { }

	function DateComponent.Internal:normalizeStandardTime(target)
		local number = tonumber(target)

		if number < 10 then
			return "0" .. target
		else
			return target
		end
	end

	function DateComponent.Interface:from(date)
		return string.format(
			"%s-%s-%sT%s:%s:%s.000Z",

			DateComponent.Internal:normalizeStandardTime(date.year),
			DateComponent.Internal:normalizeStandardTime(date.month),
			DateComponent.Internal:normalizeStandardTime(date.day),
			DateComponent.Internal:normalizeStandardTime(date.hour),
			DateComponent.Internal:normalizeStandardTime(date.min),
			DateComponent.Internal:normalizeStandardTime(date.sec)
		)
	end

	function DateComponent.Interface:fromNow()
		local date = os.date("*t")

		return DateComponent.Interface:from(date)
	end

	return DateComponent.Interface
end