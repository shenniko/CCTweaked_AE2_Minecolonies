-- Version: 1.1
-- requestFilter.lua - Filters item names or descriptions that should not use ME

local requestFilter = {}

-- List of words that imply we shouldn't use ME to fulfill
local skipKeywords = {
    "Food", "Fuel", "Flowers", "Compostable", "Smeltable Ore", "Stack List"
}

-- List of common equipment keywords
local equipmentKeywords = {
    "Hoe", "Axe", "Pickaxe", "Shovel", "Sword", "Helmet", "Chestplate", "Leggings", "Boots", "Bow", "Shield"
}

function requestFilter.shouldSkipItem(name)
    for _, word in ipairs(skipKeywords) do
        if name:find(word) then return true end
    end
    return false
end

function requestFilter.isEquipment(name)
    for _, word in ipairs(equipmentKeywords) do
        if name:find(word) then return true end
    end
    return false
end

return requestFilter
