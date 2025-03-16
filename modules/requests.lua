-- Version: 1.9.1
-- requests.lua - Display colony requests with sectioned views

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

local function formatItemName(raw)
    local name = raw:match(":(.+)") or raw
    return name:gsub("_", " "):gsub("^%s+", "")
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

local function drawRequestTable(mon, x1, y1, x2, y2, title, list)
    display.drawTitledBox(mon, x1, y1, x2, y2, title, colors.lightBlue, colors.black, colors.cyan)

    local row = y1 + 2
    local contentWidth = x2 - x1 - 2

    local qtyW = 5
    local itemW = 22
    local statusW = 10
    local jobW = 10
    local colonistW = contentWidth - (qtyW + itemW + statusW + jobW + 4)

    local qtyX = x1 + 2
    local itemX = qtyX + qtyW + 1
    local statusX = itemX + itemW + 1
    local jobX = statusX + statusW + 1
    local colonistX = jobX + jobW + 1

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
    mon.write(string.rep("-", contentWidth))
    row = row + 1

    for _, req in ipairs(list) do
        if row >= y2 - 1 then break end

        local item = req.items[1] and (req.items[1].displayName or req.items[1].name) or "?"
        local count = req.count or 1
        local job, name = splitRoleAndName(req.target or "")
        local niceName = formatItemName(item)
        local status = "Pending"

        niceName = niceName:sub(1, itemW)
        status = status:sub(1, statusW)
        job = job:sub(1, jobW)
        name = name:sub(1, colonistW)

        mon.setCursorPos(qtyX, row)
        mon.setTextColor(colors.yellow)
        mon.write(string.format("%-4s", count .. "x"))

        mon.setCursorPos(itemX, row)
        mon.write(niceName)

        mon.setCursorPos(statusX, row)
        mon.write(status)

        mon.setCursorPos(jobX, row)
        mon.write(job)

        mon.setCursorPos(colonistX, row)
        mon.write(name)

        row = row + 1
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
    local mainBoxX1, mainBoxY1, mainBoxX2, mainBoxY2 = 1, 1, w, h
    display.drawTitledBox(mon, mainBoxX1, mainBoxY1, mainBoxX2, mainBoxY2, "MineColonies Work Requests", colors.lightBlue, colors.black, colors.cyan)

    local builders, workers = {}, {}
    for _, req in ipairs(list) do
        local job, _ = splitRoleAndName(req.target or "")
        if job:lower() == "builder" then
            table.insert(builders, req)
        else
            table.insert(workers, req)
        end
    end

    local splitHeight = math.floor((h - 4) / 2)
    local leftX1, leftX2 = 2, w - 20
    local rightX1, rightX2 = w - 18, w - 2
    local box1Y1, box1Y2 = 3, 3 + splitHeight
    local box2Y1, box2Y2 = box1Y2 + 1, h - 2

    drawRequestTable(mon, leftX1, box1Y1, leftX2, box1Y2, "Builder Requests", builders)
    drawRequestTable(mon, leftX1, box2Y1, leftX2, box2Y2, "Worker Requests", workers)

    display.drawTitledBox(mon, rightX1, box1Y1, rightX2, box2Y2, "Menu", colors.lightBlue, colors.black, colors.lime)
    mon.setTextColor(colors.lime)
    mon.setCursorPos(rightX1 + 2, box1Y1 + 2)
    mon.write("[1] Requests")
    mon.setCursorPos(rightX1 + 2, box1Y1 + 4)
    mon.write("[2] Overview")
    mon.setCursorPos(rightX1 + 2, box1Y1 + 6)
    mon.write("[3] Resources")
end

return requests
