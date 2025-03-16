-- Version: 1.0
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

-- Download a file from GitHub
local function downloadFile(path, target)
    local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
    print("[Downloading] " .. path)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        if target:find("/") then
            local dir = target:match("^(.*)/")
            if dir and not fs.exists(dir) then
                fs.makeDir(dir)
            end
        end

        local file = fs.open(target, "w")
        file.write(content)
        file.close()
        print("[✓] Saved as " .. target)
        return true
    else
        print("[X] Failed to download " .. path)
        return false
    end
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
        shell.run("dashboard.lua")
    else
        print("[Error] dashboard.lua not found.")
    end
end

-- Run it!
updateAll()
runDashboard()
