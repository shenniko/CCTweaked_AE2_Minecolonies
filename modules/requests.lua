-- Version: 1.9
-- requests.lua - Display colony requests inside a filled border box

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Format raw item string into something readable
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

-- Extract job and name from request target string
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

    -- Safe colony data fetch
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
    display.drawBoxWithTitle(mon, boxX1, boxY1, boxX2, boxY2, "MineColonies Work Requests", colors.gray)

    local row = boxY1 + 2

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    -- Define column layout
    local qtyW   = 5
    local itemW  = 30
    local jobW   = 12
    local nameW  = w - (qtyW + itemW + jobW + 8)

    local qtyX   = boxX1 + 2
    local itemX  = qtyX + qtyW + 1
    local jobX   = itemX + itemW + 1
    local nameX  = jobX + jobW + 1

    -- Table Headers
    display.drawTableHeaders(mon, row, {
        { x = qtyX,  label = "Qty" },
        { x = itemX, label = "Item" },
        { x = jobX,  label = "Job" },
        { x = nameX, label = "Colonist" }
    })

    row = row + 1
    display.drawHorizontalLine(mon, row)
    row = row + 1

    for _, req in ipairs(list) do
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item)

        mon.setCursorPos(qtyX, row)
        mon.setTextColor(colors.yellow)
        mon.write(string.format("%-4s", count .. "x"))

        mon.setCursorPos(itemX, row)
        mon.write(niceName:sub(1, itemW):gsub("^%s+", ""))  -- trim front spaces

        mon.setCursorPos(jobX, row)
        mon.write(job:sub(1, jobW))

        mon.setCursorPos(nameX, row)
        mon.write(name:sub(1, nameW))

        row = row + 1
        if row >= h - 1 then break end
    end
end

return requests
