-- Version: 1.0
-- requests.lua - Display colony requests on main monitor

local display = require("modules.display")
local colony = require("modules.colony")

local requests = {}

function requests.drawRequests(mon, colonyPeripheral)
    display.clear(mon)
    display.printHeader(mon, "MineColonies Work Requests")

    local list = colony.getWorkRequests(colonyPeripheral)
    local row = 3

    if #list == 0 then
        display.printLine(mon, row, "No active work requests", colors.gray)
        return
    end

    for _, req in ipairs(list) do
        local item = req.items[1] and req.items[1].name or "?"
        local line = string.format("%dx %s -> %s", req.count, item, req.target or "unknown")
        display.printLine(mon, row, line, colors.yellow)
        row = row + 1
    end
end

return requests
