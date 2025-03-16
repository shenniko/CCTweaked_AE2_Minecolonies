-- Version: 2.1
-- requests.lua - Display colony requests with status column and split panels

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Format raw item string
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " ")
end

-- Split role and name
local function splitRoleAndName(target)
    if not target or target == "" then return "Unknown", "Unknown" end
    local words = {}
    for word in target:gmatch("%S+") do table.insert(words, word) end
    return words[1] or "Unknown", table.concat(words, " ", 2)
end

-- Placeholder for ME/inventory/crafting integration
local function getItemStatus(itemName)
    -- TODO: Replace with actual ME or colony inventory check
    return "Pending"
end

-- Draw a bordered table of requests in a boxed area
local function drawRequestTable(mon, x1, y1, x2, y2, title, list)
    display.drawTitledBox(mon, x1, y1, x2, y2, title, colors.lightBlue, colors.black, colors.cyan)

    local qtyW, itemW, statusW, jobW, nameW = 4, 20, 10, 10, 16
    local spacing = 1

    local qtyX = x1 + 2
    local itemX = qtyX + qtyW + spacing
    local statusX = itemX + itemW + spacing
    local jobX = statusX + statusW + spacing
    local nameX = jobX + jobW + spacing

    local row = y1 + 2
    mon.setCursorPos(qtyX, row)
    mon.setTextColor(colors.lightGray)
    mon.write("Qty")
    mon.setCursorPos(itemX, row)
    mon.write("Item")
    mon.setCursorPos(statusX, row)
    mon.write("Status")
    mon.setCursorPos(jobX, row)
    mon.write("Job")
    mon.setCursorPos(nameX, row)
    mon.write("Colonist")

    row = row + 1
    mon.setCursorPos(qtyX, row)
    mon.write(string.rep("-", x2 - x1 - 2))
    row = row + 1

    for _, req in ipairs(list) do
        if row >= y2 then break end
        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item)
        local status = getItemStatus(item)

        mon.setTextColor(colors.yellow)
        mon.setCursorPos(qtyX, row)
        mon.write(string.format("%-3s", count .. "x"))

        mon.setCursorPos(itemX, row)
        mon.write(niceName:sub(1, itemW))

        mon.setCursorPos(statusX, row)
        mon.write(status:sub(1, statusW))

        mon.setCursorPos(jobX, row)
        mon.write(job:sub(1, jobW))

        mon.setCursorPos(nameX, row)
        mon.write(name:sub(1, nameW))

        row = row + 1
    end
end

function requests.drawRequests(mon, colonyPeripheral)
    display.clear(mon)
    local w, h = mon.getSize()
    local rightPanelX = w - 25

    -- Full outer box
    display.drawTitledBox(mon, 1, 1, w, h, "MineColonies Work Requests", colors.lightBlue, colors.black, colors.cyan)

    -- Fetch requests
    local ok, allRequests = pcall(colony.getWorkRequests, colonyPeripheral)
    if not ok or type(allRequests) ~= "table" then
        display.printLine(mon, 3, "Error loading requests", colors.red)
        return
    end

    -- Group by role
    local builders, workers = {}, {}
    for _, req in ipairs(allRequests) do
        local job = (req.target or ""):match("^(%S+)")
        if job and job:lower() == "builder" then
            table.insert(builders, req)
        else
            table.insert(workers, req)
        end
    end

    -- Builder Requests Panel
    drawRequestTable(mon, 2, 3, rightPanelX - 1, math.floor(h / 2), "Builder Requests", builders)

    -- Worker Requests Panel
    drawRequestTable(mon, 2, math.floor(h / 2) + 1, rightPanelX - 1, h - 2, "Worker Requests", workers)

    -- Side Menu
    display.drawTitledBox(mon, rightPanelX, 3, w - 1, h - 2, "Menu", colors.blue, colors.black, colors.lime)
    local menuItems = { "Requests", "Overview", "Resources" }
    for i, label in ipairs(menuItems) do
        mon.setCursorPos(rightPanelX + 2, 4 + i)
        mon.setTextColor(colors.lime)
        mon.write("[" .. i .. "] " .. label)
    end
end

return requests
