-- Version: 1.20
-- logger.lua - Debug + Per-File Version Viewer + Click-to-Update

local logger = {}

local LOG = {}
local MAX_ENTRIES = 100
local SCROLL_OFFSET = 0
local MODE = "log" -- or "versions"
local MON_WIDTH = 0
local MON_HEIGHT = 0
local UPDATE_BUTTONS = {} -- Tracks x/y range per file row

-- === GitHub Config ===
local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"

-- Add log entry
function logger.add(msg, color)
    table.insert(LOG, { text = msg, color = color or colors.white })
    if #LOG > MAX_ENTRIES then table.remove(LOG, 1) end
end

-- === Helpers ===
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
        tracked[path] = true
    end
    for path in contents:gmatch('"%s*(modules/[^"]+%.lua)"') do
        tracked[path] = true
    end
    if fs.exists("dashboard.lua") then tracked["dashboard.lua"] = true end

    -- Convert to sorted array
    local result = {}
    for path in pairs(tracked) do table.insert(result, path) end
    table.sort(result)
    return result
end

-- GitHub pull for a file
local function pullFile(path)
    local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
    local response = http.get(url)
    if not response then
        logger.add("[X] Failed to fetch " .. path, colors.red)
        return false
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
    return true
end

-- === Draw UI Buttons ===
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

-- === Draw Version + Per-file Update Buttons ===
local function drawVersions(mon)
    mon.clear()
    drawButtons(mon)
    UPDATE_BUTTONS = {}

    local files = getTrackedFiles()
    local row = 3

    for i, path in ipairs(files) do
        if row >= MON_HEIGHT then break end

        local version = getFileVersion(path)
        mon.setCursorPos(2, row)
        mon.setTextColor(colors.white)
        mon.write(("%-36s"):format(path:sub(1, 36)))

        mon.setCursorPos(MON_WIDTH - 16, row)
        mon.setTextColor(colors.orange)
        mon.write("v" .. version)

        -- Draw per-file Update button
        local updateLabel = "[Update]"
        local updateX = MON_WIDTH - #updateLabel - 1
        mon.setCursorPos(updateX, row)
        mon.setTextColor(colors.yellow)
        mon.write(updateLabel)

        -- Track clickable range
        UPDATE_BUTTONS[row] = { file = path, x1 = updateX, x2 = updateX + #updateLabel - 1 }
        row = row + 1
    end
end

-- === Draw Log ===
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

-- === Main draw ===
function logger.draw(mon)
    MON_WIDTH, MON_HEIGHT = mon.getSize()
    if MODE == "versions" then
        drawVersions(mon)
    else
        drawLog(mon)
    end
end

-- === Handle Clicks ===
function logger.handleTouch(x, y)
    if y == 1 then
        if x >= 2 and x <= 18 then
            MODE = "versions"
        elseif x >= MON_WIDTH - 19 and x <= MON_WIDTH then
            MODE = "log"
        end
        return
    end

    -- Check if clicked [Update] on any row
    if UPDATE_BUTTONS[y] then
        local btn = UPDATE_BUTTONS[y]
        if x >= btn.x1 and x <= btn.x2 then
            logger.add("Updating " .. btn.file .. "...", colors.yellow)
            local ok = pullFile(btn.file)
            if ok then logger.draw(peripheral.wrap(config.MONITOR_DEBUG)) end
        end
    end
end

return logger
