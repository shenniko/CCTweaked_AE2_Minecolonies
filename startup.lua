-- Version: 1.1
-- startup.lua - Minimal launcher with work request display

-- === GitHub Repo Info ===
local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"

-- === Files to Fetch ===
local FILES = {
  -- Core Modules
  { path = "modules/peripherals.lua", target = "modules/peripherals.lua" },
  { path = "modules/config.lua", target = "modules/config.lua" },

  -- Display Logic
  { path = "modules/display.lua", target = "modules/display.lua" },
  { path = "modules/colony.lua", target = "modules/colony.lua" },
  { path = "modules/requests.lua", target = "modules/requests.lua" }
}

-- === Download Helper ===
local function downloadFile(path, target)
  local url = ("https://raw.githubusercontent.com/%s/%s/%s"):format(REPO, BRANCH, path)
  print("Downloading: " .. path)
  local response = http.get(url)
  if not response then
    print("Failed to download " .. path)
    return false
  end

  local content = response.readAll()
  response.close()

  if target:find("/") then
    local dir = target:match("^(.*)/")
    if dir and not fs.exists(dir) then fs.makeDir(dir) end
  end

  local file = fs.open(target, "w")
  file.write(content)
  file.close()
  print("Saved: " .. target)
  return true
end

-- === Fetch Required Files ===
local function updateAll()
  print("\nSyncing modules...")
  for _, f in ipairs(FILES) do
    downloadFile(f.path, f.target)
  end
end

-- === Run Display ===
local function run()
  local peripherals = require("modules.peripherals")
  local config = require("modules.config")
  local requests = require("modules.requests")

  local monitor = peripheral.wrap(config.MONITOR_MAIN)
  local colony = peripherals.getColonyIntegrator()

  if monitor and colony then
    requests.drawRequests(monitor, colony)
  else
    print("Monitor or ColonyIntegrator not found.")
  end
end

-- === Execute ===
updateAll()
run()
