-- meutils.lua
-- Utility functions for interacting with ME Bridge peripheral

local meutils = {}

-- Converts ME item list into a lookup table: itemName => item
function meutils.buildItemLookup(items)
    local itemMap = {}
    for _, item in ipairs(items) do
        itemMap[item.name] = item
    end
    return itemMap
end

-- Determines if the item should be handled via ME auto-crafting
-- Skips tools, food, compost, etc.
function meutils.shouldUseME(itemName, desc)
    return not (
        desc:find("Tool of class") or
        itemName:match("Hoe|Shovel|Axe|Pickaxe|Bow|Sword|Shield|Helmet|Cap|Chestplate|Tunic|Pants|Leggings|Boots") or
        itemName:match("Compostable|Fuel|Food|Flowers|Smeltable Ore|Stack List")
    )
end

-- Attempts to export the item to a connected inventory
-- Returns amount actually exported
function meutils.exportItem(meBridge, item, count, destination)
    return meBridge.exportItem({ name = item, count = count }, destination) or 0
end

-- Tries to craft an item if not already being crafted
-- Returns true if successfully started
function meutils.tryCraft(meBridge, item, count)
    if meBridge.isItemCrafting({ name = item }) then
        return false -- Already crafting
    else
        return meBridge.craftItem({ name = item, count = count })
    end
end

return meutils

