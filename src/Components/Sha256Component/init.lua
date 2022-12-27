--[[
	Luau-Sha256 - Copyright (C) 2021, Luc Rodriguez (Aliases : Shambi, StyledDev).

	Copyright (C) 2021, Luc Rodriguez (Aliases : Shambi, StyledDev).
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	(Original Repository can be found here: https://github.com/Shambi-0/Luau-Sha256)
]]--

local bit32_band = bit32.band
local bit32_rshift = bit32.rshift
local bit32_bxor = bit32.bxor
local bit32_rrotate = bit32.rrotate
local bit32_bnot = bit32.bnot

local string_len = string.len
local string_format = string.format
local string_reverse = string.reverse
local string_char = string.char
local string_rep = string.rep
local string_byte = string.byte
local string_gsub = string.gsub

return function()
	local Sha256Component = { }

	Sha256Component.Interface = { }
	Sha256Component.Internal = { }
	Sha256Component.Cache = setmetatable({ }, { __mode = "kv" })
	Sha256Component.Hash, Sha256Component.Permutations = {
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
	}, {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	}

	function Sha256Component.Internal:processNumber(input, size)
		local result = ""

		for _ = 1, size do
			local remainder = bit32_band(input, 255)

			result ..= string_char(remainder)
			input = bit32_rshift(input - remainder, 8)
		end

		return string_reverse(result)
	end

	function Sha256Component.Internal:processMessage(message, messageSize)
		messageSize = Sha256Component.Internal:processNumber(8 * messageSize, 8)
		message ..= string_format("\128%s", string_rep("\0", 64 - bit32_band(messageSize + 9, 63)) .. messageSize)

		assert(#message % 64 == 0, "Preprocessed content does not have a valid length of 64 bytes, and can not continue.")

		return message
	end

	function Sha256Component.Internal:stringTo232BitNumber(input, offset)
		local output = 0

		for index = offset, offset + 3 do
			output *= 256
			output += string_byte(input, index)
		end

		return output
	end

	function Sha256Component.Internal:digestBlock(content, offset)
		local offsets = {}

		for index = 1, 16 do
			offsets[index] = Sha256Component.Internal:stringTo232BitNumber(content,  offset + (index - 1) * 4)
		end

		for index = 17, 64 do
			local value = offsets[index - 15]
			local section0 = bit32_bxor(bit32_rrotate(value, 7), bit32_rrotate(value, 18), bit32_rshift(value, 3))

			value = offsets[index - 2]
			offsets[index] = offsets[index - 16] + section0 + offsets[index - 7] + bit32_bxor(bit32_rrotate(value, 17), bit32_rrotate(value, 19), bit32_rshift(value, 10))
		end

		local a = Sha256Component.Hash[1]
		local b = Sha256Component.Hash[2]
		local c = Sha256Component.Hash[3]
		local d = Sha256Component.Hash[4]
		local e = Sha256Component.Hash[5]
		local f = Sha256Component.Hash[6]
		local g = Sha256Component.Hash[7]
		local h = Sha256Component.Hash[8]

		for index = 1, 64 do
			local section0 = bit32_bxor(bit32_rrotate(a, 2), bit32_rrotate(a, 13), bit32_rrotate(a, 22))
			local maj = bit32_bxor(bit32_band(a, b), bit32_band(a, c), bit32_band(b, c))
			local tail2 = section0 + maj
			local section1 = bit32_bxor(bit32_rrotate(e, 6), bit32_rrotate(e, 11), bit32_rrotate(e, 25))
			local chunk = bit32_bxor(bit32_band(e, f), bit32_band(bit32_bnot(e), g))

			local tail1 = h + section1 + chunk + Sha256Component.Permutations[index] + offsets[index]

			h, g, f, e, d, c, b, a = g, f, e, d + tail1, c, b, a, tail1 + tail2
		end

		for index, value in { a, b, c, d, e, f, g, h } do
			Sha256Component.Hash[index] = bit32_band(Sha256Component.Hash[index] + value)
		end
	end

	function Sha256Component.Internal:digestString(message, salt)
		local contentLength = string_len(message)
		local content = Sha256Component.Internal:processMessage(message .. (salt or ""), contentLength)

		contentLength = string_len(message)
		for index = 1, contentLength, 64 do
			Sha256Component.Internal:digestBlock(content, index)
		end

		local hashTable = {}

		for Index, Value in Sha256Component.Hash do
			hashTable[Index] = Sha256Component.Internal:processNumber(Value, 4)
		end

		return string_gsub(table.concat(hashTable), ".", function(Character)
			return string_format("%02x", string_byte(Character))
		end)
	end

	function Sha256Component.Interface:hash(message, salt)
		if Sha256Component.Cache[message] then
			return Sha256Component.Cache[message]
		else
			Sha256Component.Cache[message] = Sha256Component.Internal:digestString(message, salt or "")
		end

		return Sha256Component.Cache[message]
	end

	return Sha256Component.Interface
end