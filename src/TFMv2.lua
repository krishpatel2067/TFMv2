local TFM = {}

TFM._SECS_MIN_ = 60
TFM._SECS_HR_ = 60 * TFM._SECS_MIN_
TFM._SECS_DAY_ = 24 * TFM._SECS_HR_			
TFM.SECS_MON = 30 * TFM._SECS_DAY_
TFM.SECS_YR = 365 * TFM._SECS_DAY_

local NUM_UNITS = 7
local IN_SECS = {1, TFM._SECS_MIN_, TFM._SECS_HR_, TFM._SECS_DAY_, TFM.SECS_MON, TFM.SECS_YR}
local IN_MS = {1, 1000, 1000 * TFM._SECS_MIN_, 1000 * TFM._SECS_HR_, 1000 * TFM._SECS_DAY_, 1000 * TFM.SECS_MON, 1000 * TFM.SECS_YR}
local UNITS = {'ms', 'sec', 'min', 'hr', 'day', 'mon', 'yr'}
local FORMATS = {'s', 'S', 'm', 'h', 'd', 'M', 'y'}

---------------------------------------------==========[[ PRIVATE FUNCTIONS ]]==========---------------------------------------------

-- custom assert with a higher stack level
local function assert(condition, msg, lvl)

	if condition then return end

	error(msg, (lvl or 1) + 2)

end

local function convert(num, isMil, max)

	max = max or 'hr'

	do

		assert(type(num) == 'number', 'expected int, got ' .. type(num) .. ' (arg #1)', 2)
		assert(num % 1 == 0, 'expected int, got float (arg #1)', 2)
		assert(table.find(UNITS, max), 'invalid max unit (arg #2)', 2)

	end

	local converted = {}
	local sub = isMil and 1 or 0
	local start = 2 - sub
	local toUse = isMil and IN_MS or IN_SECS

	-- init to 0
	for i = start, NUM_UNITS do
		
		converted[UNITS[i]] = 0

	end

	start = table.find(UNITS, max) - 1 + sub

	-- fill it up
	for i = start, 1, -1 do

		if num == 0 then break end

		converted[UNITS[i + 1 - sub]] = math.floor(num / toUse[i])
		num %= toUse[i]

	end

	return converted

end

---------------------------------------------==========[[ CONSUMER FUNCTIONS ]]==========---------------------------------------------

function TFM.SetSeconds(dict)

	for i, v in pairs(dict) do

		if i:match('SECS_%a+') and TFM[i] then

			local unit = i:split('_')[2]:lower()
			local index = table.find(UNITS, unit)

			TFM[i] = v
			IN_SECS[index - 1] = v
			IN_MS[index] = 1000 * v

		end

	end

end

function TFM.FormatStr(converted, formatStr)

	for i = 1, NUM_UNITS do

		-- %% for a literal % and * is for 0 or more of that char
		-- this line determines how many times to iterate, which is to do it for as many formating parts found
		-- it includes %a, %a(sin/plu), %02a, etc.
		local _, iter = string.gsub(formatStr, '%%%A*' .. FORMATS[i], '')

		for _ = 1, iter do

			-- check any conditional plurals (in the format of %a(singular_term\1plural_term)  )
			local capture = string.match(formatStr, '%%' .. FORMATS[i] .. '%(([%C]*%c[%C]*)%)')		-- use %c for control char, %C for everything else

			if capture then

				local sin, plu = unpack(capture:split(capture:match('%c')))
				local val = converted[UNITS[i]] ~= 1 and plu or sin
				local toRepl = '%%' .. FORMATS[i] .. '%([%C]*%c[%C]*%)'
				
				formatStr = string.gsub(formatStr, toRepl, converted[UNITS[i]] and val or '', 1)

			else

				-- captures the parts between % and the specifier for string.format
				capture = string.match(formatStr, '%%(%A*)' .. FORMATS[i])
				local repl = converted[UNITS[i]] and string.format('%' .. capture .. 's', converted[UNITS[i]]) or ''

				formatStr = string.gsub(formatStr, '%%%A*' .. FORMATS[i], repl)

			end

		end

	end

	return formatStr

end

function TFM.ConvertMil(ms, max)

	assert(max ~= 'ms', 'cannot set max to ms (arg #2)')
	return convert(ms, true, max)

end

function TFM.Convert(sec, max)

	assert(max ~= 'ms' or max ~= 'sec', 'cannot set max to ms or sec (arg #2)')
	return convert(sec, false, max)

end

return TFM