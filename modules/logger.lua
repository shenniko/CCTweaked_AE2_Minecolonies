-- Version: 1.01
-- logger.lua - Toggleable debug log and file version viewer

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

-- Helper: Read version from file
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

-- Helper: Get list of .lua files (recursively)
local function getAllLuaFiles(dir)
    local files = {}
    for _, item in ipairs(fs.list(dir)) do
        local path = dir .. "/" .. item
        if fs.isDir(path) then
            local subfiles = getAllLuaFiles(path)
            for _, f in ipairs(subfiles) do
                table.insert(files, f)
            end
        elseif item:match("%.lua$") then
            table.insert(files, path)
        end
    end
    return files
end

-- Draw toggle buttons (row 1)
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
    local files = getAllLuaFiles("") -- From root

    table.sort(files)

    for _, path in ipairs(files) do
        if row >= MON_HEIGHT then break end
        local version = getFileVersion(path)
        mon.setCursorPos(2, row)
        mon.write(("%-40s"):format(path:sub(1, 40)))
        mon.setCursorPos(MON_WIDTH - 8, row)
        mon.setTextColor(colors.orange)
        mon.write("v" .. version)
        mon.setTextColor(colors.white)
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

-- Public: draw current mode
function logger.draw(mon)
    MON_WIDTH, MON_HEIGHT = mon.getSize()

    if MODE == "versions" then
        drawVersions(mon)
    else
        drawLog(mon)
    end
end

-- Public: handle monitor touch event
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
