-- Version: 1.0
-- dashboard.lua
-- Central dashboard that uses modules & peripherals manager

-- === Modules ===
local display = require("modules.display")
local logger = require("modules.logger")
local colonyUtil = require("modules.colony")
local meutils = require("modules.meutils")
local workhandler = require("modules.workhandler")
local config = require("modules.config")
local peripherals = require("modules.peripherals")

-- === Configuration ===
local STORAGE_SIDE = config.ME_STORAGE_SIDE
local TIME_BETWEEN_SCANS = config.TIME_BETWEEN_SCANS

-- === Setup Peripherals ===
local monitor_main = peripherals.getMainMonitor()
local monitor_debug = peripherals.getDebugMonitor()
local colony = peripherals.getColonyIntegrator()

if not monitor_main then error("Main monitor not found") end
if not monitor_debug then error("Debug monitor not found") end
if not colony then error("Colony Integrator not found") end

monitor_main.setTextScale(config.TEXT_SCALE)
monitor_debug.setTextScale(config.TEXT_SCALE)
monitor_main.setBackgroundColor(colors.black)
monitor_debug.setBackgroundColor(colors.black)
monitor_main.clear()
monitor_debug.clear()

local MAIN_WIDTH, MAIN_HEIGHT = monitor_main.getSize()

-- === Timer Display ===
local function displayTimer(mon, t)
    local now = os.time()
    local cycle = "day"
    local cycle_color = colors.orange

    if now >= 6 and now < 18 then
        cycle = "day"
        cycle_color = colors.yellow
    elseif now >= 18 and now < 19.5 then
        cycle = "sunset"
        cycle_color = colors.orange
    elseif now >= 19.5 or now < 5 then
        cycle = "night"
        cycle_color = colors.red
    end

    local timeText = string.format("Time: %s [%s]", textutils.formatTime(now, false), cycle)
    local remainingText = (cycle == "night")
        and "Remaining: PAUSED"
        or string.format("Remaining: %ss", t)

    local width = mon.getSize()
    mon.setCursorPos(1, 1)
    mon.setBackgroundColor(colors.black)
    mon.write(string.rep(" ", width))

    mon.setCursorPos(1, 1)
    mon.setTextColor(cycle_color)
    mon.write(timeText)

    local timer_color = (cycle == "night") and colors.red
        or (t < 5 and colors.red or (t < 15 and colors.yellow or colors.orange))

    mon.setCursorPos(width - #remainingText + 1, 1)
    mon.setTextColor(timer_color)
    mon.write(remainingText)

    mon.setTextColor(colors.white)
end

-- === Draw lower colonist/construction boxes ===
local function drawLowerBoxes(mon, citizens, buildings, topRow)
    display.drawBox(mon, 1, topRow, 38, MAIN_HEIGHT, " Colonists ")
    display.drawBox(mon, 39, topRow, MAIN_WIDTH, MAIN_HEIGHT, " Construction ")
    display.mPrintRowJustified(mon, topRow - 1, "center",
        "Key:Provided (green)|Scheduled (orange)|Crafting (yellow)|Failed (red)|Skipped (gray)",
        colors.white)

    local y1, y2 = topRow + 1, topRow + 1

    for _, c in ipairs(citizens) do
        mon.setCursorPos(2, y1)
        mon.write(string.format("%s", c.name):sub(1, 36))
        mon.setCursorPos(20, y1)
        mon.write("HP:" .. math.floor(c.health))
        y1 = y1 + 1
        if y1 > MAIN_HEIGHT - 1 then break end
    end

    for _, b in ipairs(buildings) do
        local cleanedName = b.name:gsub("^.*building%.", ""):gsub("^.*colonies%.", "")
        local nameText = cleanedName:sub(1, 14)
        local statusText = ("(" .. b.status .. ")"):sub(1, MAIN_WIDTH - 40 - #nameText - 2)
        mon.setCursorPos(40, y2)
        mon.write(nameText .. " " .. statusText)
        y2 = y2 + 1
        if y2 > MAIN_HEIGHT - 1 then break end
    end
end

-- === Cycle ===
local function runCycle()
    local citizens = colonyUtil.getColonyStatus(colony)
    workhandler.scanAndDisplay(monitor_main, STORAGE_SIDE, MAIN_HEIGHT, citizens)
    local buildings = colonyUtil.getConstructionStatus(colony)
    drawLowerBoxes(monitor_main, citizens, buildings, math.floor(MAIN_HEIGHT / 2) + 1)
    logger.draw(monitor_debug)
end

-- === Loop ===
local current_run = TIME_BETWEEN_SCANS
runCycle()
displayTimer(monitor_main, current_run)

local TIMER = os.startTimer(1)

while true do
    local e = { os.pullEvent() }

    if e[1] == "timer" and e[2] == TIMER then
        local now = os.time()
        if now >= 5 and now < 19.5 then
            current_run = current_run - 1
            if current_run <= 0 then
                runCycle()
                current_run = TIME_BETWEEN_SCANS
            end
        end
        logger.draw(monitor_debug)
        displayTimer(monitor_main, current_run)
        TIMER = os.startTimer(1)
    elseif e[1] == "monitor_touch" then
        os.cancelTimer(TIMER)
        runCycle()
        current_run = TIME_BETWEEN_SCANS
        displayTimer(monitor_main, current_run)
        TIMER = os.startTimer(1)
    end
end
