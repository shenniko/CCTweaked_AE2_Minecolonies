-- startup.lua - Auto-updater and launcher for ME Warehouse Dashboard

local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"
local FILES = {
  { path = "MEWarehouse_MultiMonitor.lua", target = "dashboard.lua" },
  { path = "modules/display.lua", target = "modules/display.lua" },
  { path = "modules/logger.lua", target = "modules/logger.lua" },
  { path = "modules/colony.lua", target = "modules/colony.lua" },
  { path = "modules/meutils.lua", target = "modules/meutils.lua" }
}

local function downloadFile(path, target)
  local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
  print("[Downloading] " .. path)
  local response = http.get(url)
  if response then
    local content = response.readAll()
    response.close()
    local f = fs.open(target, "w")
    f.write(content)
    f.close()
    print("[✓] " .. target)
    return true
  else
    print("[X] Failed to download " .. path)
    return false
  end
end

local function updateAll()
  for _, file in ipairs(FILES) do
    downloadFile(file.path, file.target)
  end
end

local function runDashboard()
  if fs.exists("dashboard.lua") then
    shell.run("dashboard.lua")
  else
    print("[Error] dashboard.lua not found.")
  end
end

-- Update & launch
updateAll()
runDashboard()
