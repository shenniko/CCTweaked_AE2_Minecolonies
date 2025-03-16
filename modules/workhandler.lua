-- workhandler.lua
-- Scans colony requests, attempts to fulfill via ME,
-- and categorizes for UI display

local workhandler = {}

local logger = require("modules.logger")
local colonyUtil = require("modules.colony")
local display = require("modules.display")
local meutils = require("modules.meutils")

-- Process all work requests and render categorized summary
function workhandler.scanAndDisplay(mon, colonyPeripheral, meBridge, storageSide, screenHeight)
    -- Setup categories
    local builder_list, nonbuilder_list, equipment_list = {}, {}, {}

    -- Build item lookup table
    local items = meBridge.listItems()
    local itemMap = meutils.buildItemLookup(items)
    local workRequests = colonyPeripheral.getRequests()

    for _, request in ipairs(workRequests) do
        local name = request.name
        local item = request.items[1].name
        local desc = request.desc
        local count = request.count
        local provided = 0
        local target = colonyUtil.extractTargetName(request.target)
        local color = colors.blue

        local useME = meutils.shouldUseME(item, desc)

        if useME then
            -- Try exporting item
            if itemMap[item] then
                provided = meutils.exportItem(meBridge, item, count, storageSide)
            end

            -- Try crafting if not enough provided
            if provided < count then
                if meBridge.isItemCrafting({ name = item }) then
                    color = colors.yellow
                    logger.add("[Crafting] " .. item, colors.yellow)
                elseif meutils.tryCraft(meBridge, item, count) then
                    color = colors.orange
                    logger.add("[Scheduled] " .. count .. " x " .. item, colors.orange)
                else
                    color = colors.red
                    logger.add("[Failed] " .. item, colors.red)
                end
            else
                color = colors.lime
                logger.add("[Provided] " .. count .. " x " .. item, colors.lime)
            end
        else
            color = colors.gray
            logger.add("[Skipped] " .. name .. " [" .. target .. "]", colors.gray)
        end

        -- Create UI entry
        local entry = {
            name = name,
            item = item,
            target = target,
            needed = count,
            provided = provided,
            color = color
        }

        -- Categorize
        if desc:find("of class") then
            table.insert(equipment_list, entry)
        elseif target:find("Builder") then
            table.insert(builder_list, entry)
        else
            table.insert(nonbuilder_list, entry)
        end
    end

    -- Render UI summary
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
