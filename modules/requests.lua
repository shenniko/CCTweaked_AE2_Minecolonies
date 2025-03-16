-- Version: 1.3
-- requests.lua - Display colony requests in tidy right-aligned columns

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

local function splitRoleAndName(target)
    if not target or target == "" then return "Unknown", "Unknown" end
    local words = {}
    for word in target:gmatch("%S+") do table.insert(words, word) end
    if #words < 2 then return "Unknown", target end
    local job = words[1]
    local name = table.concat(words, " ", 2)
    return job, name
end

function requests.drawRequests(mon, colonyPeripheral)
    display.clear(mon)
    display.printHeader(mon, "MineColonies Work Requests")

    local list = colony.getWorkRequests(colonyPeripheral)
    local w, _ = mon.getSize()
    local row = 3

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Define column widths
    local qtyW = 4
    local jobW = 10
    local nameW = 22
    local spacing = 2
    local itemW = w - (qtyW + jobW + nameW + spacing * 3)

    -- Header
    mon.setTextColor(colors.lightGray)
    mon.setCursorPos(2, row)
    mon.write(string.format("%-" .. qtyW .. "s", "Qty"))
    mon.setCursorPos(2 + qtyW + spacing, row)
    mon.write("Item")
    mon.setCursorPos(w - (jobW + nameW + spacing * 2), row)
    mon.write(string.format("%-" .. jobW .. "s", "Job"))
    mon.setCursorPos(w - nameW + 1, row)
    mon.write("Colonist")
    row = row + 1

    for _, req in ipairs(list) do
        local item = req.items[1] and req.items[1].name or "?"
        local count = req.count or 1
        local rawTarget = req.target or "Unknown"
        local job, name = splitRoleAndName(rawTarget)
        local niceName = formatItemName(item)

        mon.setCursorPos(2, row)
        mon.setTextColor(colors.yellow)
        mon.write(string.format("%-" .. qtyW .. "s", count .. "x"))

        mon.setCursorPos(2 + qtyW + spacing, row)
        mon.write(niceName:sub(1, itemW))

        mon.setCursorPos(w - (jobW + nameW + spacing * 2), row)
        mon.write(string.format("%-" .. jobW .. "s", job))

        mon.setCursorPos(w - nameW + 1, row)
        mon.write(name:sub(1, nameW))

        row = row + 1
    end
end

return requests
