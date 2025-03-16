-- Version: 1.1
-- installer.lua - Force-downloads the latest startup.lua

local repo = "shenniko/CCTweaked_AE2_Minecolonies"
local branch = "main"
local url = ("https://raw.githubusercontent.com/%s/%s/startup.lua"):format(repo, branch)

print("Installing startup.lua from GitHub...")
local response = http.get(url .. "?t=" .. os.epoch("utc")) -- bust cache

if response then
    local content = response.readAll()
    response.close()

    if fs.exists("startup.lua") then
        fs.delete("startup.lua")
        print("Deleted old startup.lua")
    end

    local file = fs.open("startup.lua", "w")
    file.write(content)
    file.close()

    print("Installed latest startup.lua")
    print("Rebooting to launch dashboard...")
    sleep(2)
    os.reboot()
else
    print("Failed to download startup.lua")
    print("Check your repo or internet connection.")
end
