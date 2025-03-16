-- dashboard.lua
-- Main ME Warehouse Dashboard script using modular design

-- === 🧩 Module Imports ===
local display = require("modules.display")
local logger = require("modules.logger")
local colonyUtil = require("modules.colony")
local meutils = require("modules.meutils")
local workhandler = require("modules.workhandler")
local config = require("modules.config")

-- === ⚙️ Configuration ===
local STORAGE_SIDE = config.ME_STORAGE_SIDE
local TIME_BETWEEN_SCANS = config.TIME_BETWEEN_SCANS

-- === 🖥️ Peripheral Setup ===
local monitor_main = peripheral.wrap(config.MONITOR_MAIN)
local monitor_debug = peripheral.wrap(config.MONITOR_DEBUG)
local meBridge = peripheral.find("meBridge")
local colony = peripheral.find("colonyIntegrator")

if not monitor_main then error(config.MONITOR_MAIN .. " not found") end
if not monitor_debug then error(config.MONITOR_DEBUG .. " not found") end
if not meBridge then error("ME Bridge not found") end
if not colony then error("Colony Integrator not found") end

monitor_main.setTextScale(config.TEXT_SCALE)
monitor_debug.setTextScale(config.TEXT_SCALE)
monitor_main.setBackgroundColor(colors.black)
monitor_debug.setBackgroundColor(colors.black)
monitor_main.clear()
monitor_debug.clear()

-- === 📏 Dimensions ===
local MAIN_WIDTH, MAIN_HEIGHT = monitor_main.getSize()
local DEBUG_WIDTH, DEBUG_HEIGHT = monitor_debug.getSize()

-- === ⏲️ Timer Display Function ===
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

    -- Clear the top line
    mon.setCursorPos(1, 1)
    mon.setBackgroundColor(colors.black)
    mon.write(string.rep(" ", width))

    -- Print left-aligned time
    mon.setCursorPos(1, 1)
    mon.setTextColor(cycle_color)
    mon.write(timeText)

    -- Print right-aligned remaining time
    local timer_color = (cycle == "night") and colors.red
        or (t < 5 and colors.red or (t < 15 and colors.yellow or colors.orange))

    mon.setCursorPos(width - #remainingText + 1, 1)
    mon.setTextColor(timer_color)
    mon.write(remainingText)

    mon.setTextColor(colors.white)
end

-- === 🧱 Draw Colonist & Construction Boxes ===
local function drawLowerBoxes(mon, citizens, buildings, topRow)
    display.drawBox(mon, 1, topRow, 38, MAIN_HEIGHT, " Colonists ")
    display.drawBox(mon, 39, topRow, MAIN_WIDTH, MAIN_HEIGHT, " Construction ")

    -- Color legend above boxes
    display.mPrintRowJustified(mon, topRow - 1, "center",
        "Key: ✔ Provided (green) | ↻ Crafting (yellow) | ↝ Scheduled (orange) | ✖ Failed (red) | ● Skipped (gray)",
        colors.white)

    local y1, y2 = topRow + 1, topRow + 1

    for _, c in ipairs(citizens) do
        mon.setCursorPos(2, y1)
        local fullName = string.format("%s", c.name)
        mon.write(fullName:sub(1, 36))
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

-- === 🔁 Full Update Cycle ===
local function runCycle()
    local citizens = colonyUtil.getColonyStatus(colony)
    workhandler.scanAndDisplay(monitor_main, colony, meBridge, STORAGE_SIDE, MAIN_HEIGHT, citizens)
    local buildings = colonyUtil.getConstructionStatus(colony)
    drawLowerBoxes(monitor_main, citizens, buildings, math.floor(MAIN_HEIGHT / 2) + 1)
    logger.draw(monitor_debug)
end

-- === 🚀 Startup ===
local current_run = TIME_BETWEEN_SCANS
runCycle()
displayTimer(monitor_main, current_run)

-- === ⏲️ Main Loop ===
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
