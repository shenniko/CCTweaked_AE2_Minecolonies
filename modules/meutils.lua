-- meutils.lua
-- ME system helper functions (ATM10 / Advanced Peripherals 0.7+)

local meutils = {}

-- Builds a lookup table of all items currently in the ME system
-- Format: itemMap[itemName] = { count = number, displayName = string, ... }
function meutils.getItemMap(meBridge)
    local map = {}
    for _, item in ipairs(meBridge.listItems()) do
        map[item.name] = item
    end
    return map
end

-- Checks if a given item is currently being crafted
-- Returns true if in progress, false if not
function meutils.isCrafting(meBridge, itemName)
    return meBridge.isItemCrafting({ name = itemName }) or false
end

-- Tries to start crafting a specific item in a given count
-- Returns true if the task was scheduled
function meutils.startCraft(meBridge, itemName, count)
    return meBridge.craftItem({ name = itemName, count = count or 1 }) or false
end

-- Attempts to export items from ME system to a connected inventory
-- Returns the number of items actually exported (or 0 if failed)
function meutils.tryExport(meBridge, itemName, count, toSide)
    return meBridge.exportItem({ name = itemName, count = count or 1 }, toSide) or 0
end

-- Determines if the requested amount of an item is available
-- Returns: (bool canExport, number availableCount)
function meutils.canExport(itemMap, itemName, required)
    local entry = itemMap[itemName]
    if entry and entry.count >= required then
        return true, entry.count
    end
    return false, entry and entry.count or 0
end

return meutils
