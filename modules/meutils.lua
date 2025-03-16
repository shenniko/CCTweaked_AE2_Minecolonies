-- meutils.lua - Safe ME Bridge functions for ATM10

local meutils = {}

function meutils.getItemMap(meBridge)
    local map = {}
    local success, items = pcall(function() return meBridge.listItems() end)
    if success and items then
        for _, item in ipairs(items) do
            map[item.name] = item
        end
    end
    return map
end

function meutils.isCrafting(meBridge, itemName)
    local success, result = pcall(function()
        return meBridge.isItemCrafting({ name = itemName })
    end)
    return success and result or false
end

function meutils.startCraft(meBridge, itemName, count)
    local success, result = pcall(function()
        return meBridge.craftItem({ name = itemName, count = count or 1 })
    end)
    return success and result or false
end

function meutils.tryExport(meBridge, itemName, count, toSide)
    local success, result = pcall(function()
        return meBridge.exportItem({ name = itemName, count = count or 1 }, toSide)
    end)
    return success and result or 0
end

function meutils.canExport(itemMap, itemName, required)
    local entry = itemMap[itemName]
    if entry and entry.count >= required then
        return true, entry.count
    end
    return false, entry and entry.count or 0
end

return meutils
