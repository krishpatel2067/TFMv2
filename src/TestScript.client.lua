--[[==[

This script showcases the different functions of TFMv2 along with a GUI timer system (from the demo)!

]==]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TFMv2 = require(ReplicatedStorage:WaitForChild('TFMv2'))

---------------------------------------------==========[[ SHOWCASE ]]==========---------------------------------------------

local ui = script.Parent:WaitForChild('TFMv2 Showcase')
local bkg = ui:WaitForChild('Background')
local stopwatch = bkg:WaitForChild('Stopwatch')
local basicCountdown = bkg:WaitForChild('BasicCountdown')
local sentence = bkg:WaitForChild('Sentence')

local initWait = 10

               ---------------------------==========[[ BASIC COUNTDOWN ]]==========---------------------------

-- this section simply uses seconds and the Convert() function

local secondsLeft = 1.5 * 60

local countdownThread = coroutine.wrap(function()

    wait(initWait)

    while secondsLeft >= 0 do
        
        local converted = TFMv2.Convert(secondsLeft)
        local str = TFMv2.FormatStr(converted, 'Basic Countdown: %02m:%02S')

        basicCountdown.Text = str
        secondsLeft -= 1
        wait(1)

    end

end)

               ------------------------------==========[[ STOPWATCH ]]==========------------------------------

-- this section uses milliseconds and the ConvertMil() function

-- min wait time for stopwatch (inc this to avoid performance drops)
local MIN_YIELD = 0

-- store our seconds
local total_sec = 0

local stopwatchThread = coroutine.wrap(function()
    
    wait(initWait)

    while true do
    
        -- wait() returns how long it actually yielded the script, which can fluctuate!
        total_sec += wait(MIN_YIELD)

        local converted = TFMv2.ConvertMil(math.round(total_sec * 1000)) -- round bc we only want integer ms
        local str = TFMv2.FormatStr(converted, 'Stopwatch: %02h:%02m:%02S.%03s')

        stopwatch.Text = str

    end

end)

               ------------------------------==========[[ SENTENCE ]]==========------------------------------

-- this section embeds time into a sentence with correct singular-plural usage

local cooldown = 1.5 * 60

local sentenceThread = coroutine.wrap(function()

    wait(initWait)

    while cooldown >= 0 do
        
        local converted = TFMv2.Convert(cooldown)
        local str = TFMv2.FormatStr(converted, 'Try again in %m minute%m(\1s) and %S second%S(\1s)')

        sentence.Text = str
        cooldown -= 1
        wait(1)

    end

end)

countdownThread()
stopwatchThread()
sentenceThread()

---------------------------------------------==========[[ PLAYGROUND ]]==========---------------------------------------------
-- get the currently set number of seconds in a month and a year
print(('\nCurrent defintions of units:\n\tMonth: %.0f\n\tYear: %.0f'):format(TFMv2.SECS_MON, TFMv2.SECS_YR))

-- test
print('Current 12 Months:\n', TFMv2.Convert(3600 * 24 * 30 * 12, 'yr'))        -- says 12 months, not 1 year

-- set them
TFMv2.SetSeconds({
    SECS_YR = 3600 * 24 * 30 * 12       -- a year is now 360 days (but exactly 12 months)
})

print(('\nNew defintions of units:\n\tMonth: %.0f\n\tYear: %.0f'):format(TFMv2.SECS_MON, TFMv2.SECS_YR))

print('New 12 months:\n', TFMv2.Convert(3600 * 24 * 30 * 12, 'yr'))        -- says 1 year, not 12 months

local dummyTab = {
    hr = 2,
    min = 1,
    sec = 5,
}

local dummyTabDay = {
    day = 1,
    hr = 2,
    min = 1,
    sec = 5,
}

local formatStr1 = 'there %h(is\1are) %h hour%h(\1s), %m minute%m(\1s), and %S second%S(\1s) left'

print('\n\n')

-- plural formatting
print('\nTest1: plural formatting')
print(TFMv2.FormatStr(dummyTab, formatStr1))      -- there are 2 hours, 1 minute, and 5 seconds

-- auto-clear formatting if it doesn't exist in a table
print('\nTest2: auto-clear formatting')
print(TFMv2.FormatStr(dummyTab, 'Day: %d - %02h:%02m:%02S'))      -- Day:  - 02:01:05

-- include certain characters if unit exists in a table using plural format (both have the same format string!)
print('\nTest3: use plural format for a "does exist" condition')
print(TFMv2.FormatStr(dummyTab, '%d(Day: \7f Day: )%d%d( - \1 - )%02h:%02m:%02S'))     -- 02:01:05
print(TFMv2.FormatStr(dummyTabDay, '%d(Day: \1 Day: )%d%d( - \1 - )%02h:%02m:%02S'))      -- Day: 1 - 02:01:05