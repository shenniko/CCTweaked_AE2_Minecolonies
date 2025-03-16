-- Version: 1.10
-- logger.lua - Debug + Version + Auto-Repair Updater

local logger = {}

local LOG = {}
local MAX_ENTRIES = 100
local SCROLL_OFFSET = 0
local MODE = "log" -- or "versions"
local MON_WIDTH = 0
local MON_HEIGHT = 0

-- === GitHub Repo Config ===
local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"

-- === Logging ===
function logger.add(msg, color)
    table.insert(LOG, { text = msg, color = color or colors.white })
    if #LOG > MAX_ENTRIES then table.remove(LOG, 1) end
end

-- === File Utilities ===
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
        table.insert(tracked, path)
    end
    if not table.concat(tracked, " "):find("dashboard.lua") and fs.exists("dashboard.lua") then
        table.insert(tracked, "dashboard.lua")
    end
    return tracked
end

-- === GitHub Puller ===
local function pullFile(path)
    local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
    local response = http.get(url)
    if not response then
        logger.add("[X] Failed to fetch " .. path, colors.red)
        return
    end

    local data = response.readAll()
    response.close()

    if path:find("/") then
        local dir = path:match("^(.*)/")
        if dir and not fs.exists(dir) then fs.makeDir(dir) end
    end

    local file = fs.open(path, "w")
    file.write(data)
    file.close()
    logger.add("[✓] Updated: " .. path, colors.lime)
end

-- === Button Bar ===
local function drawButtons(mon)
    mon.setCursorPos(2, 1)
    mon.setTextColor(colors.cyan)
    mon.write("[ Show Versions ]")

    mon.setCursorPos(24, 1)
    mon.setTextColor(colors.yellow)
    mon.write("[ 🔄 Update Files ]")

    local rightBtn = "[ Show Debug Log ]"
    mon.setCursorPos(MON_WIDTH - #rightBtn - 1, 1)
    mon.setTextColor(colors.red)
    mon.write(rightBtn)

    mon.setTextColor(colors.white)
end

-- === UI: Version View ===
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

-- === UI: Debug Log ===
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

-- === Public Draw ===
function logger.draw(mon)
    MON_WIDTH, MON_HEIGHT = mon.getSize()
    if MODE == "versions" then
        drawVersions(mon)
    else
        drawLog(mon)
    end
end

-- === Button Click Handler ===
function logger.handleTouch(x, y)
    if y == 1 then
        if x >= 2 and x <= 18 then
            MODE = "versions"
        elseif x >= 24 and x <= 43 then
            MODE = "log"
            logger.add("Updating files...", colors.yellow)
            local files = getTrackedFiles()
            for _, file in ipairs(files) do
                pullFile(file)
                sleep(0.2) -- Let server breathe
            end
            logger.add("Update complete.", colors.lime)
        elseif x >= MON_WIDTH - 19 and x <= MON_WIDTH then
            MODE = "log"
        end
    end
end

return logger
