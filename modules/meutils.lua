-- Version: 1.0
-- meutils.lua - Crash-safe ME Bridge utility functions

local meutils = {}
local peripherals = require("modules.peripherals")

-- Get item list from ME and build map
function meutils.getItemMap()
    local bridge = peripherals.getMEBridge()
    if not bridge then return {} end

    local success, items = pcall(bridge.listItems)
    if not success or not items then return {} end

    local map = {}
    for _, item in ipairs(items) do
        map[item.name] = item
    end
    return map
end

-- Check if item is being crafted
function meutils.isCrafting(itemName)
    local bridge = peripherals.getMEBridge()
    if not bridge then return false end

    local ok, result = pcall(function()
        return bridge.isItemCrafting({ name = itemName })
    end)
    return ok and result or false
end

-- Start crafting item
function meutils.startCraft(itemName, count)
    local bridge = peripherals.getMEBridge()
    if not bridge then return false end

    local ok, result = pcall(function()
        return bridge.craftItem({ name = itemName, count = count or 1 })
    end)
    return ok and result or false
end

-- Export item to specified side
function meutils.tryExport(itemName, count, side)
    local bridge = peripherals.getMEBridge()
    if not bridge then return 0 end

    local ok, result = pcall(function()
        return bridge.exportItem({ name = itemName, count = count or 1 }, side)
    end)
    return ok and result or 0
end

-- Check if an item exists in ME with required count
function meutils.canExport(itemMap, itemName, required)
    local entry = itemMap[itemName]
    if entry and entry.count >= required then
        return true, entry.count
    end
    return false, entry and entry.count or 0
end

return meutils
