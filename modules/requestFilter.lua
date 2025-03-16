-- Version: 1.0
-- requestFilter.lua
-- Determines whether a colony request should be skipped

local filter = {}

-- Add terms/types you want to skip here
local blockedKeywords = {
    "Tool of class",
    "Hoe", "Shovel", "Pickaxe", "Axe", "Sword", "Helmet", "Boots", "Chestplate", "Leggings",
    "Compostable", "Food", "Fuel", "Flower", "Ore"
}

-- Check if a request should be skipped based on name or description
function filter.shouldSkip(request)
    local name = request.name:lower()
    local desc = request.desc:lower()

    for _, keyword in ipairs(blockedKeywords) do
        if name:find(keyword:lower()) or desc:find(keyword:lower()) then
            return true
        end
    end

    return false
end

return filter
