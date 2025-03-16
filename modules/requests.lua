-- Version: 2.0
-- requests.lua - Display colony requests in separate builder/worker boxes + side menu

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
    return words[1], table.concat(words, " ", 2)
end

-- Render request list into a box
local function drawRequestSection(mon, x1, y1, x2, y2, title, list)
    display.drawTitledBox(mon, x1, y1, x2, y2, title, colors.cyan, colors.black, colors.cyan)

    local qtyW = 5
    local itemW = 25
    local jobW = 10
    local nameW = x2 - x1 - (qtyW + itemW + jobW + 8)

    local qtyX = x1 + 2
    local itemX = qtyX + qtyW + 1
    local jobX = itemX + itemW + 1
    local nameX = jobX + jobW + 1

    local row = y1 + 2

    -- Header row
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

    -- Separator
    mon.setCursorPos(qtyX, row)
    mon.write(string.rep("-", x2 - x1 - 2))
    row = row + 1

    -- Content rows
    for _, req in ipairs(list) do
        if row >= y2 then break end

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

function requests.drawRequests(mon, colonyPeripheral)
    local w, h = mon.getSize()
    local list = {}

    local ok, result = pcall(colony.getWorkRequests, colonyPeripheral)
    if ok and type(result) == "table" then list = result end

    display.clear(mon)
    display.drawTitledBox(mon, 1, 1, w, h, "MineColonies Work Requests", colors.lightBlue, colors.black, colors.cyan)

    -- Split into builder / worker lists
    local builders, workers = {}, {}
    for _, req in ipairs(list) do
        local job = req.target:lower():match("^(%w+)")
        if job == "builder" then
            table.insert(builders, req)
        else
            table.insert(workers, req)
        end
    end

    -- Layout
    local padding = 2
    local contentW = w - 20 -- leave space for right-side menu
    local midY = math.floor(h / 2)

    -- Builder box (top left)
    drawRequestSection(mon, padding, 3, contentW, midY - 1, "Builder Requests", builders)

    -- Worker box (bottom left)
    drawRequestSection(mon, padding, midY + 1, contentW, h - 2, "Worker Requests", workers)

    -- Side Menu
    display.drawTitledBox(mon, contentW + 2, 3, w - 2, h - 2, "Menu", colors.cyan, colors.black, colors.white)
    mon.setCursorPos(contentW + 4, 5)
    mon.setTextColor(colors.lime)
    mon.write("[1] Requests")
    mon.setCursorPos(contentW + 4, 7)
    mon.write("[2] Overview")
    mon.setCursorPos(contentW + 4, 9)
    mon.write("[3] Resources")
end

return requests
