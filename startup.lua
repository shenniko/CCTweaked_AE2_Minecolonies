-- Version: 2.0
-- startup.lua - Auto-updater and launcher for ME Dashboard

local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"

-- Files to download from GitHub
local FILES = {
    -- Core
    { path = "dashboard.lua", target = "dashboard.lua" },

    -- Modules
    { path = "modules/peripherals.lua", target = "modules/peripherals.lua" },
    { path = "modules/display.lua", target = "modules/display.lua" },
    { path = "modules/logger.lua", target = "modules/logger.lua" },
    { path = "modules/colony.lua", target = "modules/colony.lua" },
    { path = "modules/meutils.lua", target = "modules/meutils.lua" },
    { path = "modules/workhandler.lua", target = "modules/workhandler.lua" },
    { path = "modules/requestFilter.lua", target = "modules/requestFilter.lua" },

    -- Config
    { path = "modules/config.lua", target = "modules/config.lua" }
}

-- Download a file from GitHub and overwrite it safely
local function downloadFile(path, target)
    local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
    print("[⬇] Downloading: " .. path)

    local response = http.get(url .. "?t=" .. os.epoch("utc"))  -- cache bust
    if not response then
        print("Failed to download: " .. path)
        return false
    end

    local content = response.readAll()
    response.close()

    if not content or #content == 0 then
        print("Empty content received for: " .. path)
        return false
    end

    -- Ensure directory exists
    if target:find("/") then
        local dir = target:match("^(.*)/")
        if dir and not fs.exists(dir) then
            fs.makeDir(dir)
        end
    end

    -- Check if file is different
    local oldContent = ""
    if fs.exists(target) then
        local f = fs.open(target, "r")
        oldContent = f.readAll()
        f.close()
    end

    if oldContent ~= content then
        if fs.exists(target) then fs.delete(target) end
        local f = fs.open(target, "w")
        f.write(content)
        f.close()
        print("Updated: " .. target)
    else
        print("No change: " .. target)
    end

    os.sleep(0.1) -- slight delay to ensure flush
    return true
end

-- Update all files
local function updateAll()
    for _, file in ipairs(FILES) do
        downloadFile(file.path, file.target)
    end
end

-- Run the main dashboard
local function runDashboard()
    if fs.exists("dashboard.lua") then
        print("\n[▶] Launching dashboard...\n")
        os.sleep(0.2)
        shell.run("dashboard.lua")
    else
        print("dashboard.lua not found. Update may have failed.")
    end
end

-- MAIN
term.clear()
term.setCursorPos(1, 1)
print("Starting ME Dashboard Updater")
updateAll()
runDashboard()
