--[[

Module was originally written by Egor Skriptunoff and distributed under an MIT license.
It can be found here: https://github.com/Egor-Skriptunoff/pure_lua_SHA/blob/master/sha2.lua

Changelog:
	- Boatbomber: Roblox LuaU port
	- HowManySmall: LuaU Optimizations
	- Datalink: Reduction in method scope

--]]

local bit32_band = bit32.band
local bit32_bxor = bit32.bxor

local sha3_RC_lo, sha3_RC_hi = {}, {}
local hi_factor_keccak, sh_reg = 0, 29

local HEX64, lanes_index_base

local TWO_POW_2 = 2 ^ 2
local TWO_POW_3 = 2 ^ 3
local TWO_POW_4 = 2 ^ 4
local TWO_POW_5 = 2 ^ 5
local TWO_POW_6 = 2 ^ 6
local TWO_POW_7 = 2 ^ 7
local TWO_POW_8 = 2 ^ 8
local TWO_POW_9 = 2 ^ 9
local TWO_POW_10 = 2 ^ 10
local TWO_POW_11 = 2 ^ 11
local TWO_POW_12 = 2 ^ 12
local TWO_POW_13 = 2 ^ 13
local TWO_POW_14 = 2 ^ 14
local TWO_POW_15 = 2 ^ 15
local TWO_POW_17 = 2 ^ 17
local TWO_POW_18 = 2 ^ 18
local TWO_POW_19 = 2 ^ 19
local TWO_POW_20 = 2 ^ 20
local TWO_POW_21 = 2 ^ 21
local TWO_POW_22 = 2 ^ 22
local TWO_POW_23 = 2 ^ 23
local TWO_POW_24 = 2 ^ 24
local TWO_POW_25 = 2 ^ 25
local TWO_POW_26 = 2 ^ 26
local TWO_POW_27 = 2 ^ 27
local TWO_POW_28 = 2 ^ 28
local TWO_POW_29 = 2 ^ 29
local TWO_POW_30 = 2 ^ 30
local TWO_POW_31 = 2 ^ 31
local TWO_POW_32 = 2 ^ 32

local function keccak_feed(lanes_lo, lanes_hi, str, offs, size, block_size_in_bytes)
	-- This is an example of a Lua function having 79 local variables :-)
	-- offs >= 0, size >= 0, size is multiple of block_size_in_bytes, block_size_in_bytes is positive multiple of 8
	local RC_lo, RC_hi = sha3_RC_lo, sha3_RC_hi
	local qwords_qty = block_size_in_bytes / 8
	for pos = offs, offs + size - 1, block_size_in_bytes do
		for j = 1, qwords_qty do
			local a, b, c, d = string.byte(str, pos + 1, pos + 4)
			lanes_lo[j] = bit32_bxor(lanes_lo[j], ((d * 256 + c) * 256 + b) * 256 + a)
			pos = pos + 8
			a, b, c, d = string.byte(str, pos - 3, pos)
			lanes_hi[j] = bit32_bxor(lanes_hi[j], ((d * 256 + c) * 256 + b) * 256 + a)
		end

		local L01_lo, L01_hi, L02_lo, L02_hi, L03_lo, L03_hi, L04_lo, L04_hi, L05_lo, L05_hi, L06_lo, L06_hi, L07_lo, L07_hi, L08_lo, L08_hi, L09_lo, L09_hi, L10_lo, L10_hi, L11_lo, L11_hi, L12_lo, L12_hi, L13_lo, L13_hi, L14_lo, L14_hi, L15_lo, L15_hi, L16_lo, L16_hi, L17_lo, L17_hi, L18_lo, L18_hi, L19_lo, L19_hi, L20_lo, L20_hi, L21_lo, L21_hi, L22_lo, L22_hi, L23_lo, L23_hi, L24_lo, L24_hi, L25_lo, L25_hi = lanes_lo[1], lanes_hi[1], lanes_lo[2], lanes_hi[2], lanes_lo[3], lanes_hi[3], lanes_lo[4], lanes_hi[4], lanes_lo[5], lanes_hi[5], lanes_lo[6], lanes_hi[6], lanes_lo[7], lanes_hi[7], lanes_lo[8], lanes_hi[8], lanes_lo[9], lanes_hi[9], lanes_lo[10], lanes_hi[10], lanes_lo[11], lanes_hi[11], lanes_lo[12], lanes_hi[12], lanes_lo[13], lanes_hi[13], lanes_lo[14], lanes_hi[14], lanes_lo[15], lanes_hi[15], lanes_lo[16], lanes_hi[16], lanes_lo[17], lanes_hi[17], lanes_lo[18], lanes_hi[18], lanes_lo[19], lanes_hi[19], lanes_lo[20], lanes_hi[20], lanes_lo[21], lanes_hi[21], lanes_lo[22], lanes_hi[22], lanes_lo[23], lanes_hi[23], lanes_lo[24], lanes_hi[24], lanes_lo[25], lanes_hi[25]

		for round_idx = 1, 24 do
			local C1_lo = bit32_bxor(L01_lo, L06_lo, L11_lo, L16_lo, L21_lo)
			local C1_hi = bit32_bxor(L01_hi, L06_hi, L11_hi, L16_hi, L21_hi)
			local C2_lo = bit32_bxor(L02_lo, L07_lo, L12_lo, L17_lo, L22_lo)
			local C2_hi = bit32_bxor(L02_hi, L07_hi, L12_hi, L17_hi, L22_hi)
			local C3_lo = bit32_bxor(L03_lo, L08_lo, L13_lo, L18_lo, L23_lo)
			local C3_hi = bit32_bxor(L03_hi, L08_hi, L13_hi, L18_hi, L23_hi)
			local C4_lo = bit32_bxor(L04_lo, L09_lo, L14_lo, L19_lo, L24_lo)
			local C4_hi = bit32_bxor(L04_hi, L09_hi, L14_hi, L19_hi, L24_hi)
			local C5_lo = bit32_bxor(L05_lo, L10_lo, L15_lo, L20_lo, L25_lo)
			local C5_hi = bit32_bxor(L05_hi, L10_hi, L15_hi, L20_hi, L25_hi)

			local D_lo = bit32_bxor(C1_lo, C3_lo * 2 + (C3_hi % TWO_POW_32 - C3_hi % TWO_POW_31) / TWO_POW_31)
			local D_hi = bit32_bxor(C1_hi, C3_hi * 2 + (C3_lo % TWO_POW_32 - C3_lo % TWO_POW_31) / TWO_POW_31)

			local T0_lo = bit32_bxor(D_lo, L02_lo)
			local T0_hi = bit32_bxor(D_hi, L02_hi)
			local T1_lo = bit32_bxor(D_lo, L07_lo)
			local T1_hi = bit32_bxor(D_hi, L07_hi)
			local T2_lo = bit32_bxor(D_lo, L12_lo)
			local T2_hi = bit32_bxor(D_hi, L12_hi)
			local T3_lo = bit32_bxor(D_lo, L17_lo)
			local T3_hi = bit32_bxor(D_hi, L17_hi)
			local T4_lo = bit32_bxor(D_lo, L22_lo)
			local T4_hi = bit32_bxor(D_hi, L22_hi)

			L02_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_20) / TWO_POW_20 + T1_hi * TWO_POW_12
			L02_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_20) / TWO_POW_20 + T1_lo * TWO_POW_12
			L07_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_19) / TWO_POW_19 + T3_hi * TWO_POW_13
			L07_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_19) / TWO_POW_19 + T3_lo * TWO_POW_13
			L12_lo = T0_lo * 2 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_31) / TWO_POW_31
			L12_hi = T0_hi * 2 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_31) / TWO_POW_31
			L17_lo = T2_lo * TWO_POW_10 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_22) / TWO_POW_22
			L17_hi = T2_hi * TWO_POW_10 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_22) / TWO_POW_22
			L22_lo = T4_lo * TWO_POW_2 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_30) / TWO_POW_30
			L22_hi = T4_hi * TWO_POW_2 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_30) / TWO_POW_30

			D_lo = bit32_bxor(C2_lo, C4_lo * 2 + (C4_hi % TWO_POW_32 - C4_hi % TWO_POW_31) / TWO_POW_31)
			D_hi = bit32_bxor(C2_hi, C4_hi * 2 + (C4_lo % TWO_POW_32 - C4_lo % TWO_POW_31) / TWO_POW_31)

			T0_lo = bit32_bxor(D_lo, L03_lo)
			T0_hi = bit32_bxor(D_hi, L03_hi)
			T1_lo = bit32_bxor(D_lo, L08_lo)
			T1_hi = bit32_bxor(D_hi, L08_hi)
			T2_lo = bit32_bxor(D_lo, L13_lo)
			T2_hi = bit32_bxor(D_hi, L13_hi)
			T3_lo = bit32_bxor(D_lo, L18_lo)
			T3_hi = bit32_bxor(D_hi, L18_hi)
			T4_lo = bit32_bxor(D_lo, L23_lo)
			T4_hi = bit32_bxor(D_hi, L23_hi)

			L03_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_21) / TWO_POW_21 + T2_hi * TWO_POW_11
			L03_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_21) / TWO_POW_21 + T2_lo * TWO_POW_11
			L08_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_3) / TWO_POW_3 + T4_hi * TWO_POW_29 % TWO_POW_32
			L08_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_3) / TWO_POW_3 + T4_lo * TWO_POW_29 % TWO_POW_32
			L13_lo = T1_lo * TWO_POW_6 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_26) / TWO_POW_26
			L13_hi = T1_hi * TWO_POW_6 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_26) / TWO_POW_26
			L18_lo = T3_lo * TWO_POW_15 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_17) / TWO_POW_17
			L18_hi = T3_hi * TWO_POW_15 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_17) / TWO_POW_17
			L23_lo = (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_2) / TWO_POW_2 + T0_hi * TWO_POW_30 % TWO_POW_32
			L23_hi = (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_2) / TWO_POW_2 + T0_lo * TWO_POW_30 % TWO_POW_32

			D_lo = bit32_bxor(C3_lo, C5_lo * 2 + (C5_hi % TWO_POW_32 - C5_hi % TWO_POW_31) / TWO_POW_31)
			D_hi = bit32_bxor(C3_hi, C5_hi * 2 + (C5_lo % TWO_POW_32 - C5_lo % TWO_POW_31) / TWO_POW_31)

			T0_lo = bit32_bxor(D_lo, L04_lo)
			T0_hi = bit32_bxor(D_hi, L04_hi)
			T1_lo = bit32_bxor(D_lo, L09_lo)
			T1_hi = bit32_bxor(D_hi, L09_hi)
			T2_lo = bit32_bxor(D_lo, L14_lo)
			T2_hi = bit32_bxor(D_hi, L14_hi)
			T3_lo = bit32_bxor(D_lo, L19_lo)
			T3_hi = bit32_bxor(D_hi, L19_hi)
			T4_lo = bit32_bxor(D_lo, L24_lo)
			T4_hi = bit32_bxor(D_hi, L24_hi)

			L04_lo = T3_lo * TWO_POW_21 % TWO_POW_32 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_11) / TWO_POW_11
			L04_hi = T3_hi * TWO_POW_21 % TWO_POW_32 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_11) / TWO_POW_11
			L09_lo = T0_lo * TWO_POW_28 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_4) / TWO_POW_4
			L09_hi = T0_hi * TWO_POW_28 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_4) / TWO_POW_4
			L14_lo = T2_lo * TWO_POW_25 % TWO_POW_32 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_7) / TWO_POW_7
			L14_hi = T2_hi * TWO_POW_25 % TWO_POW_32 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_7) / TWO_POW_7
			L19_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_8) / TWO_POW_8 + T4_hi * TWO_POW_24 % TWO_POW_32
			L19_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_8) / TWO_POW_8 + T4_lo * TWO_POW_24 % TWO_POW_32
			L24_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_9) / TWO_POW_9 + T1_hi * TWO_POW_23 % TWO_POW_32
			L24_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_9) / TWO_POW_9 + T1_lo * TWO_POW_23 % TWO_POW_32

			D_lo = bit32_bxor(C4_lo, C1_lo * 2 + (C1_hi % TWO_POW_32 - C1_hi % TWO_POW_31) / TWO_POW_31)
			D_hi = bit32_bxor(C4_hi, C1_hi * 2 + (C1_lo % TWO_POW_32 - C1_lo % TWO_POW_31) / TWO_POW_31)

			T0_lo = bit32_bxor(D_lo, L05_lo)
			T0_hi = bit32_bxor(D_hi, L05_hi)
			T1_lo = bit32_bxor(D_lo, L10_lo)
			T1_hi = bit32_bxor(D_hi, L10_hi)
			T2_lo = bit32_bxor(D_lo, L15_lo)
			T2_hi = bit32_bxor(D_hi, L15_hi)
			T3_lo = bit32_bxor(D_lo, L20_lo)
			T3_hi = bit32_bxor(D_hi, L20_hi)
			T4_lo = bit32_bxor(D_lo, L25_lo)
			T4_hi = bit32_bxor(D_hi, L25_hi)

			L05_lo = T4_lo * TWO_POW_14 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_18) / TWO_POW_18
			L05_hi = T4_hi * TWO_POW_14 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_18) / TWO_POW_18
			L10_lo = T1_lo * TWO_POW_20 % TWO_POW_32 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_12) / TWO_POW_12
			L10_hi = T1_hi * TWO_POW_20 % TWO_POW_32 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_12) / TWO_POW_12
			L15_lo = T3_lo * TWO_POW_8 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_24) / TWO_POW_24
			L15_hi = T3_hi * TWO_POW_8 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_24) / TWO_POW_24
			L20_lo = T0_lo * TWO_POW_27 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_5) / TWO_POW_5
			L20_hi = T0_hi * TWO_POW_27 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_5) / TWO_POW_5
			L25_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_25) / TWO_POW_25 + T2_hi * TWO_POW_7
			L25_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_25) / TWO_POW_25 + T2_lo * TWO_POW_7

			D_lo = bit32_bxor(C5_lo, C2_lo * 2 + (C2_hi % TWO_POW_32 - C2_hi % TWO_POW_31) / TWO_POW_31)
			D_hi = bit32_bxor(C5_hi, C2_hi * 2 + (C2_lo % TWO_POW_32 - C2_lo % TWO_POW_31) / TWO_POW_31)

			T1_lo = bit32_bxor(D_lo, L06_lo)
			T1_hi = bit32_bxor(D_hi, L06_hi)
			T2_lo = bit32_bxor(D_lo, L11_lo)
			T2_hi = bit32_bxor(D_hi, L11_hi)
			T3_lo = bit32_bxor(D_lo, L16_lo)
			T3_hi = bit32_bxor(D_hi, L16_hi)
			T4_lo = bit32_bxor(D_lo, L21_lo)
			T4_hi = bit32_bxor(D_hi, L21_hi)

			L06_lo = T2_lo * TWO_POW_3 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_29) / TWO_POW_29
			L06_hi = T2_hi * TWO_POW_3 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_29) / TWO_POW_29
			L11_lo = T4_lo * TWO_POW_18 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_14) / TWO_POW_14
			L11_hi = T4_hi * TWO_POW_18 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_14) / TWO_POW_14
			L16_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_28) / TWO_POW_28 + T1_hi * TWO_POW_4
			L16_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_28) / TWO_POW_28 + T1_lo * TWO_POW_4
			L21_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_23) / TWO_POW_23 + T3_hi * TWO_POW_9
			L21_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_23) / TWO_POW_23 + T3_lo * TWO_POW_9

			L01_lo = bit32_bxor(D_lo, L01_lo)
			L01_hi = bit32_bxor(D_hi, L01_hi)
			L01_lo, L02_lo, L03_lo, L04_lo, L05_lo = bit32_bxor(L01_lo, bit32_band(-1 - L02_lo, L03_lo)), bit32_bxor(L02_lo, bit32_band(-1 - L03_lo, L04_lo)), bit32_bxor(L03_lo, bit32_band(-1 - L04_lo, L05_lo)), bit32_bxor(L04_lo, bit32_band(-1 - L05_lo, L01_lo)), bit32_bxor(L05_lo, bit32_band(-1 - L01_lo, L02_lo))
			L01_hi, L02_hi, L03_hi, L04_hi, L05_hi = bit32_bxor(L01_hi, bit32_band(-1 - L02_hi, L03_hi)), bit32_bxor(L02_hi, bit32_band(-1 - L03_hi, L04_hi)), bit32_bxor(L03_hi, bit32_band(-1 - L04_hi, L05_hi)), bit32_bxor(L04_hi, bit32_band(-1 - L05_hi, L01_hi)), bit32_bxor(L05_hi, bit32_band(-1 - L01_hi, L02_hi))
			L06_lo, L07_lo, L08_lo, L09_lo, L10_lo = bit32_bxor(L09_lo, bit32_band(-1 - L10_lo, L06_lo)), bit32_bxor(L10_lo, bit32_band(-1 - L06_lo, L07_lo)), bit32_bxor(L06_lo, bit32_band(-1 - L07_lo, L08_lo)), bit32_bxor(L07_lo, bit32_band(-1 - L08_lo, L09_lo)), bit32_bxor(L08_lo, bit32_band(-1 - L09_lo, L10_lo))
			L06_hi, L07_hi, L08_hi, L09_hi, L10_hi = bit32_bxor(L09_hi, bit32_band(-1 - L10_hi, L06_hi)), bit32_bxor(L10_hi, bit32_band(-1 - L06_hi, L07_hi)), bit32_bxor(L06_hi, bit32_band(-1 - L07_hi, L08_hi)), bit32_bxor(L07_hi, bit32_band(-1 - L08_hi, L09_hi)), bit32_bxor(L08_hi, bit32_band(-1 - L09_hi, L10_hi))
			L11_lo, L12_lo, L13_lo, L14_lo, L15_lo = bit32_bxor(L12_lo, bit32_band(-1 - L13_lo, L14_lo)), bit32_bxor(L13_lo, bit32_band(-1 - L14_lo, L15_lo)), bit32_bxor(L14_lo, bit32_band(-1 - L15_lo, L11_lo)), bit32_bxor(L15_lo, bit32_band(-1 - L11_lo, L12_lo)), bit32_bxor(L11_lo, bit32_band(-1 - L12_lo, L13_lo))
			L11_hi, L12_hi, L13_hi, L14_hi, L15_hi = bit32_bxor(L12_hi, bit32_band(-1 - L13_hi, L14_hi)), bit32_bxor(L13_hi, bit32_band(-1 - L14_hi, L15_hi)), bit32_bxor(L14_hi, bit32_band(-1 - L15_hi, L11_hi)), bit32_bxor(L15_hi, bit32_band(-1 - L11_hi, L12_hi)), bit32_bxor(L11_hi, bit32_band(-1 - L12_hi, L13_hi))
			L16_lo, L17_lo, L18_lo, L19_lo, L20_lo = bit32_bxor(L20_lo, bit32_band(-1 - L16_lo, L17_lo)), bit32_bxor(L16_lo, bit32_band(-1 - L17_lo, L18_lo)), bit32_bxor(L17_lo, bit32_band(-1 - L18_lo, L19_lo)), bit32_bxor(L18_lo, bit32_band(-1 - L19_lo, L20_lo)), bit32_bxor(L19_lo, bit32_band(-1 - L20_lo, L16_lo))
			L16_hi, L17_hi, L18_hi, L19_hi, L20_hi = bit32_bxor(L20_hi, bit32_band(-1 - L16_hi, L17_hi)), bit32_bxor(L16_hi, bit32_band(-1 - L17_hi, L18_hi)), bit32_bxor(L17_hi, bit32_band(-1 - L18_hi, L19_hi)), bit32_bxor(L18_hi, bit32_band(-1 - L19_hi, L20_hi)), bit32_bxor(L19_hi, bit32_band(-1 - L20_hi, L16_hi))
			L21_lo, L22_lo, L23_lo, L24_lo, L25_lo = bit32_bxor(L23_lo, bit32_band(-1 - L24_lo, L25_lo)), bit32_bxor(L24_lo, bit32_band(-1 - L25_lo, L21_lo)), bit32_bxor(L25_lo, bit32_band(-1 - L21_lo, L22_lo)), bit32_bxor(L21_lo, bit32_band(-1 - L22_lo, L23_lo)), bit32_bxor(L22_lo, bit32_band(-1 - L23_lo, L24_lo))
			L21_hi, L22_hi, L23_hi, L24_hi, L25_hi = bit32_bxor(L23_hi, bit32_band(-1 - L24_hi, L25_hi)), bit32_bxor(L24_hi, bit32_band(-1 - L25_hi, L21_hi)), bit32_bxor(L25_hi, bit32_band(-1 - L21_hi, L22_hi)), bit32_bxor(L21_hi, bit32_band(-1 - L22_hi, L23_hi)), bit32_bxor(L22_hi, bit32_band(-1 - L23_hi, L24_hi))
			L01_lo = bit32_bxor(L01_lo, RC_lo[round_idx])
			L01_hi = L01_hi + RC_hi[round_idx] -- RC_hi[] is either 0 or 0x80000000, so we could use fast addition instead of slow XOR
		end

		lanes_lo[1] = L01_lo
		lanes_hi[1] = L01_hi
		lanes_lo[2] = L02_lo
		lanes_hi[2] = L02_hi
		lanes_lo[3] = L03_lo
		lanes_hi[3] = L03_hi
		lanes_lo[4] = L04_lo
		lanes_hi[4] = L04_hi
		lanes_lo[5] = L05_lo
		lanes_hi[5] = L05_hi
		lanes_lo[6] = L06_lo
		lanes_hi[6] = L06_hi
		lanes_lo[7] = L07_lo
		lanes_hi[7] = L07_hi
		lanes_lo[8] = L08_lo
		lanes_hi[8] = L08_hi
		lanes_lo[9] = L09_lo
		lanes_hi[9] = L09_hi
		lanes_lo[10] = L10_lo
		lanes_hi[10] = L10_hi
		lanes_lo[11] = L11_lo
		lanes_hi[11] = L11_hi
		lanes_lo[12] = L12_lo
		lanes_hi[12] = L12_hi
		lanes_lo[13] = L13_lo
		lanes_hi[13] = L13_hi
		lanes_lo[14] = L14_lo
		lanes_hi[14] = L14_hi
		lanes_lo[15] = L15_lo
		lanes_hi[15] = L15_hi
		lanes_lo[16] = L16_lo
		lanes_hi[16] = L16_hi
		lanes_lo[17] = L17_lo
		lanes_hi[17] = L17_hi
		lanes_lo[18] = L18_lo
		lanes_hi[18] = L18_hi
		lanes_lo[19] = L19_lo
		lanes_hi[19] = L19_hi
		lanes_lo[20] = L20_lo
		lanes_hi[20] = L20_hi
		lanes_lo[21] = L21_lo
		lanes_hi[21] = L21_hi
		lanes_lo[22] = L22_lo
		lanes_hi[22] = L22_hi
		lanes_lo[23] = L23_lo
		lanes_hi[23] = L23_hi
		lanes_lo[24] = L24_lo
		lanes_hi[24] = L24_hi
		lanes_lo[25] = L25_lo
		lanes_hi[25] = L25_hi
	end
end

local function keccak(block_size_in_bytes, digest_size_in_bytes, is_SHAKE, message)
	if type(digest_size_in_bytes) ~= "number" then
		error("Argument 'digest_size_in_bytes' must be a number", 2)
	end

	local tail, lanes_lo, lanes_hi = "", table.create(25, 0), hi_factor_keccak == 0 and table.create(25, 0)
	local result

	local function partial(message_part)
		if message_part then
			local partLength = #message_part
			if tail then
				local offs = 0
				if tail ~= "" and #tail + partLength >= block_size_in_bytes then
					offs = block_size_in_bytes - #tail
					keccak_feed(lanes_lo, lanes_hi, tail .. string.sub(message_part, 1, offs), 0, block_size_in_bytes, block_size_in_bytes)
					tail = ""
				end

				local size = partLength - offs
				local size_tail = size % block_size_in_bytes
				keccak_feed(lanes_lo, lanes_hi, message_part, offs, size - size_tail, block_size_in_bytes)
				tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
				return partial
			else
				error("Adding more chunks is not allowed after receiving the result", 2)
			end
		else
			if tail then
				local gap_start = is_SHAKE and 31 or 6
				tail = tail .. (#tail + 1 == block_size_in_bytes and string.char(gap_start + 128) or string.char(gap_start) .. string.rep("\0", (-2 - #tail) % block_size_in_bytes) .. "\128")
				keccak_feed(lanes_lo, lanes_hi, tail, 0, #tail, block_size_in_bytes)
				tail = nil

				local lanes_used = 0
				local total_lanes = math.floor(block_size_in_bytes / 8)
				local qwords = {}

				local function get_next_qwords_of_digest(qwords_qty)
					if lanes_used >= total_lanes then
						keccak_feed(lanes_lo, lanes_hi, "\0\0\0\0\0\0\0\0", 0, 8, 8)
						lanes_used = 0
					end

					qwords_qty = math.floor(math.min(qwords_qty, total_lanes - lanes_used))
					if hi_factor_keccak ~= 0 then
						for j = 1, qwords_qty do
							qwords[j] = HEX64(lanes_lo[lanes_used + j - 1 + lanes_index_base])
						end
					else
						for j = 1, qwords_qty do
							qwords[j] = string.format("%08x", lanes_hi[lanes_used + j] % 4294967296) .. string.format("%08x", lanes_lo[lanes_used + j] % 4294967296)
						end
					end

					lanes_used = lanes_used + qwords_qty
					return string.gsub(table.concat(qwords, "", 1, qwords_qty), "(..)(..)(..)(..)(..)(..)(..)(..)", "%8%7%6%5%4%3%2%1"), qwords_qty * 8
				end

				local parts = {}
				local last_part, last_part_size = "", 0

				local function get_next_part_of_digest(bytes_needed)
					bytes_needed = bytes_needed or 1
					if bytes_needed <= last_part_size then
						last_part_size = last_part_size - bytes_needed
						local part_size_in_nibbles = bytes_needed * 2
						local _result = string.sub(last_part, 1, part_size_in_nibbles)
						last_part = string.sub(last_part, part_size_in_nibbles + 1)
						return _result
					end

					local parts_qty = 0
					if last_part_size > 0 then
						parts_qty = 1
						parts[parts_qty] = last_part
						bytes_needed = bytes_needed - last_part_size
					end

					while bytes_needed >= 8 do
						local next_part, next_part_size = get_next_qwords_of_digest(bytes_needed / 8)
						parts_qty = parts_qty + 1
						parts[parts_qty] = next_part
						bytes_needed = bytes_needed - next_part_size
					end

					if bytes_needed > 0 then
						last_part, last_part_size = get_next_qwords_of_digest(1)
						parts_qty = parts_qty + 1
						parts[parts_qty] = get_next_part_of_digest(bytes_needed)
					else
						last_part, last_part_size = "", 0
					end

					return table.concat(parts, "", 1, parts_qty)
				end

				if digest_size_in_bytes < 0 then
					result = get_next_part_of_digest
				else
					result = get_next_part_of_digest(digest_size_in_bytes)
				end

			end

			return result
		end
	end

	if message then
		return partial(message)()
	else
		return partial
	end
end

do
	local function next_bit()
		local r = sh_reg % 2
		sh_reg = bit32_bxor((sh_reg - r) / 2, 142 * r)
		return r
	end

	for idx = 1, 24 do
		local lo, m = 0, nil
		for _ = 1, 6 do
			m = m and m * m * 2 or 1
			lo = lo + next_bit() * m
		end

		local hi = next_bit() * m
		sha3_RC_hi[idx], sha3_RC_lo[idx] = hi, lo + hi * hi_factor_keccak
	end
end

return function(message)
	return keccak((1600 - 2 * 256) / 8, 256 / 8, false, message)
end;
