-- Version: 1.02
-- logger.lua - Debug + File Version Viewer (auto-detects from startup.lua)

local logger = {}

local LOG = {}
local MAX_ENTRIES = 100
local SCROLL_OFFSET = 0
local MODE = "log" -- or "versions"
local MON_WIDTH = 0
local MON_HEIGHT = 0

-- Add log entry
function logger.add(msg, color)
    table.insert(LOG, { text = msg, color = color or colors.white })
    if #LOG > MAX_ENTRIES then
        table.remove(LOG, 1)
    end
end

-- Read version from first line of a file
local function getFileVersion(filename)
    if fs.exists(filename) then
        local file = fs.open(filename, "r")
        local firstLine = file.readLine() or ""
        file.close()

        local version = firstLine:match("Version:%s*([%d%.]+)")
        return version or "No version"
    else
        return "Missing"
    end
end

-- Auto-detect tracked files from startup.lua
local function getTrackedFiles()
    local tracked = {}
    if not fs.exists("startup.lua") then return tracked end

    local f = fs.open("startup.lua", "r")
    local contents = f.readAll()
    f.close()

    for path in contents:gmatch('path%s*=%s*"([^"]+)"') do
        table.insert(tracked, path)
    end

    for path in contents:gmatch('"%s*(modules/[^"]+%.lua)"') do
        if not table.contains(tracked, path) then
            table.insert(tracked, path)
        end
    end

    -- Add dashboard.lua if not explicitly included
    if not table.concat(tracked, " "):find("dashboard.lua") and fs.exists("dashboard.lua") then
        table.insert(tracked, "dashboard.lua")
    end

    return tracked
end

-- Draw top buttons
local function drawButtons(mon)
    mon.setCursorPos(2, 1)
    mon.setTextColor(colors.cyan)
    mon.write("[ Show Versions ]")

    local rightBtn = "[ Show Debug Log ]"
    mon.setCursorPos(MON_WIDTH - #rightBtn - 1, 1)
    mon.setTextColor(colors.red)
    mon.write(rightBtn)

    mon.setTextColor(colors.white)
end

-- Draw version list
local function drawVersions(mon)
    mon.clear()
    drawButtons(mon)

    local row = 3
    local files = getTrackedFiles()
    table.sort(files)

    for _, path in ipairs(files) do
        if row >= MON_HEIGHT then break end
        local version = getFileVersion(path)
        mon.setCursorPos(2, row)
        mon.setTextColor(colors.white)
        mon.write(("%-40s"):format(path:sub(1, 40)))
        mon.setCursorPos(MON_WIDTH - 8, row)
        mon.setTextColor(colors.orange)
        mon.write("v" .. version)
        row = row + 1
    end
end

-- Draw the debug log view
local function drawLog(mon)
    mon.clear()
    drawButtons(mon)

    local start = math.max(1, #LOG - MON_HEIGHT + 2 - SCROLL_OFFSET)
    local row = 3
    for i = start, math.min(#LOG, start + MON_HEIGHT - 2) do
        local log = LOG[i]
        mon.setCursorPos(2, row)
        mon.setTextColor(log.color or colors.white)
        mon.write(log.text:sub(1, MON_WIDTH - 2))
        row = row + 1
    end
    mon.setTextColor(colors.white)
end

-- Public: draw the current mode
function logger.draw(mon)
    MON_WIDTH, MON_HEIGHT = mon.getSize()
    if MODE == "versions" then
        drawVersions(mon)
    else
        drawLog(mon)
    end
end

-- Public: handle monitor touch events
function logger.handleTouch(x, y)
    if y == 1 then
        if x >= 2 and x <= 18 then
            MODE = "versions"
        elseif x >= MON_WIDTH - 19 and x <= MON_WIDTH then
            MODE = "log"
        end
    end
end

return logger
