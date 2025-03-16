-- Version: 1.11
-- meutils.lua - Utilities for interacting with the ME system via ME Bridge

local meutils = {}
local peripherals = require("modules.peripherals")

-- On-demand item lookup from ME system by item name
function meutils.getItem(itemName)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return nil end

    local success, items = pcall(meBridge.listItems)
    if not success or not items then return nil end

    for _, item in ipairs(items) do
        if item.name == itemName then
            return item
        end
    end

    return nil
end

-- Check if a given item is exportable (exists in ME and count > 0)
function meutils.canExport(itemName)
    local item = meutils.getItem(itemName)
    if item and item.count and item.count > 0 then
        return true, item.count
    end
    return false, 0
end

-- Check if a specific item is being crafted
function meutils.isCrafting(itemName)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return false end

    local success, tasks = pcall(meBridge.getCraftingCPUs)
    if not success or not tasks then return false end

    for _, cpu in ipairs(tasks) do
        if cpu.active and cpu.item and cpu.item.name == itemName then
            return true
        end
    end

    return false
end

return meutils
