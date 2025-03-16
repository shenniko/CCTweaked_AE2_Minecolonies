-- workhandler.lua
-- Processes colony requests and interacts with ME system

local workhandler = {}

local logger = require("modules.logger")
local colonyUtil = require("modules.colony")
local display = require("modules.display")
local meutils = require("modules.meutils")
local filter = require("modules.requestFilter")

-- Main scan and render logic
function workhandler.scanAndDisplay(mon, colonyPeripheral, meBridge, storageSide, screenHeight)
    local builder_list = {}
    local nonbuilder_list = {}
    local equipment_list = {}


    -- Build a lookup of current ME system contents
    local itemMap = meutils.getItemMap(meBridge)
    local workRequests = colonyPeripheral.getRequests()

    for _, request in ipairs(workRequests) do
        local itemName = request.items[1].name
        local target = colonyUtil.extractTargetName(request.target)
        local count = request.count
        local provided = 0
        local color = colors.blue

        -- Skip logic
        if filter.shouldSkip(request) then
            logger.add("[Skipped] " .. request.name .. " [" .. target .. "]", colors.gray)
            color = colors.gray
        else
            -- Try to export
            local canExport = false
            canExport, _ = meutils.canExport(itemMap, itemName, count)

            if canExport then
                provided = meutils.tryExport(meBridge, itemName, count, storageSide)
                color = colors.lime
                logger.add("[Provided] " .. count .. " x " .. itemName, colors.lime)
            elseif meutils.isCrafting(meBridge, itemName) then
                color = colors.yellow
                logger.add("[Crafting] " .. itemName, colors.yellow)
            elseif meutils.startCraft(meBridge, itemName, count) then
                color = colors.orange
                logger.add("[Scheduled] " .. count .. " x " .. itemName, colors.orange)
            else
                color = colors.red
                logger.add("[Failed] " .. itemName, colors.red)
            end
        end

        -- Create UI entry
        local entry = {
            name = request.name,
            item = itemName,
            target = target,
            needed = count,
            provided = provided,
            color = color
        }

        -- Categorize entry
        if request.desc:find("of class") then
            table.insert(equipment_list, entry)
        elseif target:find("Builder") then
            table.insert(builder_list, entry)
        else
            table.insert(nonbuilder_list, entry)
        end
    end

    -- Render to monitor
    local row = 2
    mon.clear()
    display.mPrintRowJustified(mon, 1, "center", "MineColonies Work Requests", colors.white)

    local function printCategory(title, list)
        if #list > 0 then
            display.mPrintRowJustified(mon, row, "center", title, colors.lightBlue)
            row = row + 1
            for _, entry in ipairs(list) do
                local text = string.format("%d/%d %s", entry.provided, entry.needed, entry.name)
                display.mPrintRowJustified(mon, row, "left", text, entry.color)
                display.mPrintRowJustified(mon, row, "right", entry.target, entry.color)
                row = row + 1
                if row > math.floor(screenHeight / 2) then break end
            end
            row = row + 1
        end
    end

    printCategory("Equipment", equipment_list)
    printCategory("Builder Requests", builder_list)
    printCategory("Nonbuilder Requests", nonbuilder_list)
end

return workhandler
