-- Version: 1.6
-- requests.lua - Display colony requests in a clean table using paintutils

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
    local w, h = mon.getSize()
    local row = 3

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Column widths
    local qtyW = 5
    local itemW = 30
    local jobW = 12
    local nameW = w - (qtyW + itemW + jobW + 6)

    -- Column positions
    local qtyX = 2
    local itemX = qtyX + qtyW + 1
    local jobX = itemX + itemW + 1
    local nameX = jobX + jobW + 1

    -- Headers
    mon.setCursorPos(qtyX, row)
    mon.setTextColor(colors.lightGray)
    mon.write("Qty")
    mon.setCursorPos(itemX, row)
    mon.write("Item")
    mon.setCursorPos(jobX, row)
    mon.write("Job")
    mon.setCursorPos(nameX, row)
    mon.write("Colonist")

    -- Header underline
    row = row + 1
    paintutils.drawLine(1, row, w, row, colors.gray)
    row = row + 1

    -- Print each request
    for _, req in ipairs(list) do
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item)

        mon.setCursorPos(qtyX, row)
        mon.setTextColor(colors.yellow)
        mon.write(string.format("%-4s", count .. "x"))

        mon.setCursorPos(itemX, row)
        mon.write(niceName:sub(1, itemW))

        mon.setCursorPos(jobX, row)
        mon.write(job:sub(1, jobW))

        mon.setCursorPos(nameX, row)
        mon.write(name:sub(1, nameW))

        row = row + 1
        if row >= h then break end
    end
end

return requests
