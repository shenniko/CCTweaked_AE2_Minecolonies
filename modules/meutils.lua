-- meutils.lua - Safe ME Bridge functions for ATM10

local meutils = {}
local peripherals = require("modules.peripherals")

-- Returns a list of all stored ME items, safely
function meutils.getItemMap()
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return {} end
    
    local success, items = pcall(meBridge.listItems)
    if success and items then
        local map = {}
        for _, item in ipairs(items) do
            map[item.name] = item
        end
        return map
    end
    return {}
end

function meutils.canExport(itemMap, itemName, required)
    local entry = itemMap[itemName]
    if entry and entry.count >= required then
        return true, entry.count
    end
    return false, entry and entry.count or 0
end

-- Checks if an item is being crafted
function meutils.isCrafting(itemName)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return false end
    
    local success, result = pcall(function()
        return meBridge.isItemCrafting({ name = itemName })
    end)
    return success and result or false
end

-- Tries to start crafting an item
function meutils.startCraft(itemName, count)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return false end
    
    local success, result = pcall(function()
        return meBridge.craftItem({ name = itemName, count = count or 1 })
    end)
    return success and result or false
end

-- Attempts to export an item
function meutils.tryExport(itemName, count, toSide)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return 0 end

    local success, result = pcall(function()
        return meBridge.exportItem({ name = itemName, count = count or 1 }, toSide)
    end)
    return success and result or 0
end

return meutils
