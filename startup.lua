-- Version: 1.0
-- startup.lua - Minimal launcher with only config + peripherals

-- === GitHub Repo Info ===
local REPO = "shenniko/CCTweaked_AE2_Minecolonies"
local BRANCH = "main"

-- === Files to Fetch ===
local FILES = {
  { path = "modules/peripherals.lua", target = "modules/peripherals.lua" },
  { path = "modules/config.lua", target = "modules/config.lua" }
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
  print("\nSyncing essential modules...")
  for _, f in ipairs(FILES) do
    downloadFile(f.path, f.target)
  end
end

-- === Launch Placeholder ===
local function run()
  print("\nSetup complete. No dashboard to run yet.")
end

-- === RUN ===
updateAll()
run()
