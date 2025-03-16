-- installer.lua
local repo = "shenniko/CCTweaked_AE2_Minecolonies"
local branch = "main"
local url = ("https://raw.githubusercontent.com/%s/%s/startup.lua"):format(repo, branch)

local response = http.get(url)
if response then
  local f = fs.open("startup.lua", "w")
  f.write(response.readAll())
  f.close()
  response.close()
  print("[✓] Installed startup.lua")
  print("Rebooting to launch dashboard...")
  sleep(2)
  os.reboot()
else
  print("[X] Failed to install. Check your repo URL.")
end
