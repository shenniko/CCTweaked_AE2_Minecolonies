-- Version: 1.9
-- requests.lua - Display colony requests in a structured bordered box

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Format raw item string into something human-readable
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

-- Split role and name from colony target string
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
    local list = {}

    -- Attempt to fetch work requests safely
    local ok, result = pcall(colony.getWorkRequests, colonyPeripheral)
    if ok and type(result) == "table" then
        list = result
    else
        display.clear(mon)
        display.printHeader(mon, "MineColonies Work Requests")
        display.printLine(mon, 3, "Error: Unable to fetch colony requests", colors.red)
        return
    end

    display.clear(mon)

    -- Monitor size and layout
    local w, h = mon.getSize()
    local boxX1, boxY1, boxX2, boxY2 = 1, 1, w, h
    display.drawTitledBox(mon, boxX1, boxY1, boxX2, boxY2, "MineColonies Work Requests", colors.gray, colors.black, colors.cyan)

    local row = boxY1 + 2

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Column definitions
    local qtyW = 5
    local itemW = 30
    local jobW = 12
    local nameW = w - (qtyW + itemW + jobW + 6)

    local qtyX = boxX1 + 2
    local itemX = qtyX + qtyW + 1
    local jobX = itemX + itemW + 1
    local nameX = jobX + jobW + 1

    -- Header row
    display.drawText(mon, qtyX, row, "Qty", colors.lightGray)
    display.drawText(mon, itemX, row, "Item", colors.lightGray)
    display.drawText(mon, jobX, row, "Job", colors.lightGray)
    display.drawText(mon, nameX, row, "Colonist", colors.lightGray)

    row = row + 1
    display.drawText(mon, qtyX, row, string.rep("-", w - 2), colors.gray)
    row = row + 1

    -- Rows of requests
    for _, req in ipairs(list) do
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item)

        display.drawText(mon, qtyX, row, string.format("%-4s", count .. "x"), colors.yellow)
        display.drawText(mon, itemX, row, niceName:sub(1, itemW), colors.yellow)
        display.drawText(mon, jobX, row, job:sub(1, jobW), colors.yellow)
        display.drawText(mon, nameX, row, name:sub(1, nameW), colors.yellow)

        row = row + 1
        if row >= boxY2 - 1 then break end
    end
end

return requests
