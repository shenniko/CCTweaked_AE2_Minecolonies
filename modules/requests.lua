-- Version: 1.1
-- requests.lua - Display colony requests in tidy columns

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Utility: Format item name nicely
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

-- Utility: Parse role + colonist from target string
local function splitRoleAndName(target)
    if not target or target == "" then return "Unknown", "Unknown" end
    local words = {}
    for word in target:gmatch("%S+") do table.insert(words, word) end
    if #words < 2 then return "Unknown", target end
    local job = words[1]
    local name = table.concat(words, " ", 2)
    return job, name
end

-- Main render function
function requests.drawRequests(mon, colonyPeripheral)
    display.clear(mon)
    display.printHeader(mon, "MineColonies Work Requests")

    local list = colony.getWorkRequests(colonyPeripheral)
    local row = 3

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Column headers
    mon.setTextColor(colors.lightGray)
    display.printLine(mon, row, "Qty   Item                         Job        Colonist")
    row = row + 1

    -- Render each request
    for _, req in ipairs(list) do
        local item = req.items[1] and req.items[1].name or "?"
        local count = req.count or 1
        local rawTarget = req.target or "Unknown"
        local job, name = splitRoleAndName(rawTarget)
        local niceName = formatItemName(item)

        local line = string.format("%-4dx %-26s %-10s %s", count, niceName, job, name)
        display.printLine(mon, row, line, colors.yellow)
        row = row + 1
    end
end

return requests
