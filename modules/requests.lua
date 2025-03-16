-- Version: 1.4
-- requests.lua - Display colony requests using paintutils for table layout

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Function to format item names by removing mod prefixes and replacing underscores
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

-- Function to split the role and name from the target string
local function splitRoleAndName(target)
    if not target or target == "" then return "Unknown", "Unknown" end
    local words = {}
    for word in target:gmatch("%S+") do table.insert(words, word) end
    if #words < 2 then return "Unknown", target end
    local job = words[1]
    local name = table.concat(words, " ", 2)
    return job, name
end

-- Main function to draw the requests table
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

    -- Define column widths
    local qtyW = 5
    local itemW = 20
    local jobW = 12
    local nameW = 15
    local spacing = 1

    -- Calculate starting positions of each column
    local qtyCol = 2
    local itemCol = qtyCol + qtyW + spacing
    local jobCol = itemCol + itemW + spacing
    local nameCol = jobCol + jobW + spacing

    -- Function to draw horizontal lines
    local function drawHorizontalLine(y)
        paintutils.drawLine(1, y, w, y, colors.gray)
    end

    -- Draw header
    mon.setCursorPos(qtyCol, row)
    mon.setTextColor(colors.lightGray)
    mon.write("Qty")
    mon.setCursorPos(itemCol, row)
    mon.write("Item")
    mon.setCursorPos(jobCol, row)
    mon.write("Job")
    mon.setCursorPos(nameCol, row)
    mon.write("Colonist")
    row = row + 1

    -- Draw header separator
    drawHorizontalLine(row)
    row = row + 1

    -- Iterate through the list of requests and display each
    for _, req in ipairs(list) do
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local rawTarget = req.target or "Unknown"
        local job, name = splitRoleAndName(rawTarget)
        local niceName = formatItemName(item)

        -- Write each column
        mon.setCursorPos(qtyCol, row)
        mon.setTextColor(colors.yellow)
        mon.write(string.format("%-" .. qtyW .. "s", count .. "x"))

        mon.setCursorPos(itemCol, row)
        mon.write(niceName:sub(1, itemW))

        mon.setCursorPos(jobCol, row)
        mon.write(string.format("%-" .. jobW .. "s", job))

        mon.setCursorPos(nameCol, row)
        mon.write(name:sub(1, nameW))

        row = row + 1
        if row > h then break end
    end

    -- Draw bottom border
    drawHorizontalLine(row)
end

return requests
