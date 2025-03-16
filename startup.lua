-- startup.lua - Auto-updater and launcher for ME Warehouse Dashboard (ATM10)
-- Pulls latest files from GitHub and runs the main dashboard

local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"  -- Change to "master" or another branch if needed

-- Files to download from the GitHub repository
local FILES = {
    -- Main dashboard
    { path = "dashboard.lua", target = "dashboard.lua" },

    -- Modules
    { path = "modules/display.lua", target = "modules/display.lua" },
    { path = "modules/logger.lua", target = "modules/logger.lua" },
    { path = "modules/colony.lua", target = "modules/colony.lua" },
    { path = "modules/meutils.lua", target = "modules/meutils.lua" },
    { path = "modules/workhandler.lua", target = "modules/workhandler.lua" },
    { path = "modules/requestFilter.lua", target = "modules/requestFilter.lua" },

    -- Config file
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

        -- Ensure folder exists
        if target:find("/") then
            local dir = target:match("^(.*)/")
            if not fs.exists(dir) then fs.makeDir(dir) end
        end

        local file = fs.open(target, "w")
        file.write(content)
        file.close()
        print("[✓] Saved: " .. target)
        return true
    else
        print("[X] Failed to download: " .. path)
        return false
    end
end

-- Pull all required files
local function updateAll()
    for _, file in ipairs(FILES) do
        downloadFile(file.path, file.target)
    end
end

-- Run the dashboard
local function runDashboard()
    if fs.exists("dashboard.lua") then
        shell.run("dashboard.lua")
    else
        print("[Error] dashboard.lua not found.")
    end
end

-- 🚀 Execute update and launch
updateAll()
runDashboard()
