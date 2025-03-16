-- Version: 1.9
-- requests.lua - Display colony requests in a structured box format

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

    -- Try to get colony data safely
    local ok, result = pcall(colony.getWorkRequests, colonyPeripheral)
    if ok and type(result) == "table" then
        list = result
    else
        display.clear(mon)
        display.printHeader(mon, "MineColonies Work Requests")
        display.printLine(mon, 3, "Error: Unable to get requests.", colors.red)
        return
    end

    display.clear(mon)

    local w, h = mon.getSize()
    local boxX1, boxY1, boxX2, boxY2 = 1, 1, w, h
    display.drawTitledBox(mon, boxX1, boxY1, boxX2, boxY2, "MineColonies Work Requests", colors.gray, colors.black, colors.cyan)

    local row = boxY1 + 2

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Define columns
    local qtyW = 5
    local jobW = 12
    local nameW = 22
    local spacing = 2

    local nameX = w - nameW + 1
    local jobX = nameX - spacing - jobW
    local itemX = qtyW + spacing * 2
    local qtyX = 2
    local itemW = jobX - itemX - spacing

    -- Draw headers
    mon.setCursorPos(qtyX, row)
    mon.setTextColor(colors.lightGray)
    mon.write("Qty")
    mon.setCursorPos(itemX, row)
    mon.write("Item")
    mon.setCursorPos(jobX, row)
    mon.write("Job")
    mon.setCursorPos(nameX, row)
    mon.write("Colonist")

    row = row + 1
    mon.setCursorPos(qtyX, row)
    mon.setTextColor(colors.gray)
    mon.write(string.rep("-", w - 4))  -- Leaves margin before the border
    row = row + 1

    -- Print each request row
    for _, req in ipairs(list) do
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item):gsub("^%s+", "")

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
        if row >= h - 1 then break end
    end
end

return requests
