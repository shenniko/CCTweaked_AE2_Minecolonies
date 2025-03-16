-- Version: 1.11
-- meutils.lua - AE2 ME Bridge Utilities

local peripherals = require("modules.peripherals")

local meutils = {}

-- Get item map from ME system: name => item table
function meutils.getItemMap(meBridge)
    if not meBridge then meBridge = peripherals.getMEBridge() end
    if not meBridge then return {} end

    local success, items = pcall(meBridge.listItems)
    if not success or not items then return {} end

    local map = {}
    for _, item in ipairs(items) do
        map[item.name] = item
    end
    return map
end

-- Check if item is currently being crafted
function meutils.isCrafting(itemName)
    local meBridge = peripherals.getMEBridge()
    if not meBridge then return false end

    local success, tasks = pcall(meBridge.getCraftingTasks)
    if not success or not tasks then return false end

    for _, task in ipairs(tasks) do
        if task.item and task.item.name == itemName then
            return true
        end
    end
    return false
end

return meutils
