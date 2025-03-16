-- Version: 1.9
-- requests.lua - Displays MineColonies requests grouped into subwindows

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

-- Format raw item string into something human-readable
local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " "):gsub("^%s+", "") -- trim leading spaces
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

-- Draw a list of requests in a subwindow
local function drawRequestList(mon, list, x1, y1, x2, y2, title)
    display.drawTitledBox(mon, x1, y1, x2, y2, title, colors.lightBlue, colors.black, colors.cyan)

    local qtyW = 5
    local statusW = 10
    local jobW = 12
    local colonistW = 20
    local spacing = 2

    local w = x2 - x1 + 1
    local itemW = w - (qtyW + statusW + jobW + colonistW + spacing * 4)

    local qtyX = x1 + 2
    local itemX = qtyX + qtyW + spacing
    local statusX = itemX + itemW + spacing
    local jobX = statusX + statusW + spacing
    local colonistX = jobX + jobW + spacing

    local row = y1 + 2

    -- Headers
    mon.setCursorPos(qtyX, row)
    mon.setTextColor(colors.lightGray)
    mon.write("Qty")
    mon.setCursorPos(itemX, row)
    mon.write("Item")
    mon.setCursorPos(statusX, row)
    mon.write("Status")
    mon.setCursorPos(jobX, row)
    mon.write("Job")
    mon.setCursorPos(colonistX, row)
    mon.write("Colonist")

    row = row + 1
    mon.setCursorPos(qtyX, row)
    mon.write(string.rep("-", w - 4))
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
        mon.write(niceName:sub(1, itemW))

        mon.setCursorPos(statusX, row)
        mon.write("Pending")

        mon.setCursorPos(jobX, row)
        mon.write(job:sub(1, jobW))

        mon.setCursorPos(colonistX, row)
        mon.write(name:sub(1, colonistW))

        row = row + 1
        if row >= y2 - 1 then break end
    end
end

function requests.drawRequests(mon, colonyPeripheral)
    local list = {}

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
    local menuW = 18
    local mainBoxX2 = w - menuW - 1

    -- Main window
    display.drawTitledBox(mon, 1, 1, mainBoxX2, h, "MineColonies Work Requests", colors.lightBlue, colors.black, colors.cyan)

    -- Subdivided panels
    local builderRequests = {}
    local workerRequests = {}

    for _, req in ipairs(list) do
        local job, _ = splitRoleAndName(req.target or "")
        if job:lower() == "builder" then
            table.insert(builderRequests, req)
        else
            table.insert(workerRequests, req)
        end
    end

    -- Builder Requests Panel
    drawRequestList(mon, builderRequests, 2, 2, mainBoxX2 - 1, math.floor(h / 2), "Builder Requests")

    -- Worker Requests Panel
    drawRequestList(mon, workerRequests, 2, math.floor(h / 2) + 1, mainBoxX2 - 1, h - 1, "Worker Requests")

    -- Menu box
    display.drawTitledBox(mon, mainBoxX2 + 2, 2, w - 1, h - 1, "Menu", colors.lightBlue, colors.black, colors.green)

    mon.setTextColor(colors.lime)
    mon.setCursorPos(mainBoxX2 + 4, 4)
    mon.write("[1] Requests")
    mon.setCursorPos(mainBoxX2 + 4, 5)
    mon.write("[2] Overview")
    mon.setCursorPos(mainBoxX2 + 4, 6)
    mon.write("[3] Resources")

    mon.setTextColor(colors.white)
end

return requests
