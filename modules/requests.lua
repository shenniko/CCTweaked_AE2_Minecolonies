-- Version: 1.10
-- requests.lua - Display colony requests split into sub-windows using painted borders

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
    local w, h = mon.getSize()

    -- Draw outer main box
    display.drawTitledBox(mon, 1, 1, w, h, "MineColonies Work Requests", colors.gray, colors.black, colors.cyan)

    -- Get and categorize requests
    local list = {}
    local ok, result = pcall(colony.getWorkRequests, colonyPeripheral)
    if ok and type(result) == "table" then
        list = result
    else
        display.printLine(mon, 3, "Error: Unable to get requests.", colors.red)
        return
    end

    local builders = {}
    local workers = {}

    for _, req in ipairs(list) do
        local job, _ = splitRoleAndName(req.target or "")
        if job:lower() == "builder" then
            table.insert(builders, req)
        else
            table.insert(workers, req)
        end
    end

    -- Define shared layout
    local boxW = w - 4
    local builderBoxY = 3
    local builderBoxH = math.floor((h - 5) / 2)
    local workerBoxY = builderBoxY + builderBoxH + 1
    local workerBoxH = h - workerBoxY - 1

    -- Draw Builder box
    display.drawTitledBox(mon, 3, builderBoxY, w - 2, builderBoxY + builderBoxH, "Builder Requests", colors.lightGray, colors.black)

    -- Draw Worker box
    display.drawTitledBox(mon, 3, workerBoxY, w - 2, workerBoxY + workerBoxH, "Worker Requests", colors.lightGray, colors.black)

    -- Shared function for drawing request rows
    local function drawSection(reqList, startY, maxY)
        local row = startY
        local qtyW, itemW, jobW = 5, 28, 12
        local nameW = w - (qtyW + itemW + jobW + 10)
        local qtyX = 5
        local itemX = qtyX + qtyW + 1
        local jobX = itemX + itemW + 1
        local nameX = jobX + jobW + 1

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
        mon.write(string.rep("-", w - 6))
        row = row + 1

        for _, req in ipairs(reqList) do
            if row >= maxY then break end
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
        end
    end

    drawSection(builders, builderBoxY + 2, builderBoxY + builderBoxH - 1)
    drawSection(workers, workerBoxY + 2, workerBoxY + workerBoxH - 1)
end

return requests
