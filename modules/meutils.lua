-- meutils.lua (ATM10 / Advanced Peripherals 0.7+)
-- Handles ME system interaction: listing, crafting, exporting

local meutils = {}

-- Builds a lookup table of available items in the ME system
function meutils.getItemMap(meBridge)
    local map = {}
    for _, item in ipairs(meBridge.listItems()) do
        map[item.name] = item
    end
    return map
end

-- Checks if an item is currently being crafted
function meutils.isCrafting(meBridge, itemName)
    local tasks = meBridge.getCraftingTasks()
    for _, task in ipairs(tasks) do
        if task.item.name == itemName then
            return true
        end
    end
    return false
end

-- Starts crafting a given item
function meutils.startCraft(meBridge, itemName, count)
    return meBridge.craftItem({ name = itemName, count = count or 1 })
end

-- Attempts to export an item to a connected inventory
function meutils.tryExport(meBridge, itemName, count, toSide)
    return meBridge.exportItem({ name = itemName, count = count or 1 }, toSide) or 0
end

-- Checks whether the item can be exported immediately
function meutils.canExport(itemMap, itemName, required)
    local entry = itemMap[itemName]
    if entry and entry.count >= required then
        return true, entry.count
    end
    return false, entry and entry.count or 0
end

return meutils
