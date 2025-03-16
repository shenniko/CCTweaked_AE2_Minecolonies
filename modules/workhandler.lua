-- Version: 1.12
-- workhandler.lua - Handles MineColonies work requests and ME interactions

local meutils = require("modules.meutils")
local requestFilter = require("modules.requestFilter")
local colonyUtil = require("modules.colony")
local logger = require("modules.logger")
local peripherals = require("modules.peripherals")

local workhandler = {}

function workhandler.scanAndDisplay(mon, storageSide, screenHeight, colonists)
    local builder_list, nonbuilder_list, equipment_list = {}, {}, {}

    local colony = peripherals.getColonyIntegrator()
    local meBridge = peripherals.getMEBridge()
    if not colony or not meBridge then
        logger.add("Missing colonyIntegrator or meBridge", colors.red)
        return
    end

    local requests = colony.getRequests()
    if not requests then return end

    local itemMap = meutils.getItemMap(meBridge)

    for _, req in ipairs(requests) do
        local item = req.items[1]
        local itemName = item.name
        local needed = req.count
        local provided = 0
        local desc = req.desc
        local target = colonyUtil.extractTargetName(req.target or "")
        local displayColor = colors.blue

        local isEquipment = desc:find("Tool of class") or requestFilter.isEquipment(req.name)
        local isBuilder = target:lower():find("builder")
        local useME = not requestFilter.shouldSkipItem(req.name)

        if useME then
            local entry = itemMap[itemName]
            local canExport = entry ~= nil

            if canExport then
                local success, err = pcall(function()
                    provided = meBridge.exportItem({ name = itemName, count = needed }, storageSide)
                end)
                if provided and provided >= needed then
                    displayColor = colors.lime
                    logger.add("[Provided] " .. needed .. " x " .. itemName, colors.lime)
                else
                    if meutils.isCrafting(itemName) then
                        displayColor = colors.yellow
                        logger.add("[Crafting] " .. itemName, colors.yellow)
                    elseif meBridge.craftItem({ name = itemName, count = needed }) then
                        displayColor = colors.orange
                        logger.add("[Scheduled] " .. needed .. " x " .. itemName, colors.orange)
                    else
                        displayColor = colors.red
                        logger.add("[Failed] " .. itemName, colors.red)
                    end
                end
            else
                displayColor = colors.red
                logger.add("[Missing] " .. itemName, colors.red)
            end
        else
            displayColor = colors.gray
            logger.add("[Skipped] " .. req.name .. " [" .. target .. "]", colors.gray)
        end

        -- Get citizen profession
        local profession = "Unknown"
        for _, c in ipairs(colonists or {}) do
            if c.name == target then
                profession = c.job or "Unknown"
                break
            end
        end

        local entry = {
            name = req.name,
            item = itemName,
            needed = needed,
            provided = provided,
            target = target,
            requester = req.target,
            color = displayColor,
            profession = profession
        }

        if isEquipment then
            table.insert(equipment_list, entry)
        elseif isBuilder then
            table.insert(builder_list, entry)
        else
            table.insert(nonbuilder_list, entry)
        end
    end

    -- === Drawing section ===
    mon.setCursorPos(1, 2)
    mon.setTextColor(colors.white)
    mon.clear()

    local function drawSection(title, list, startRow)
        mon.setCursorPos(1, startRow)
        mon.setTextColor(colors.lightBlue)
        mon.write(title)
        local row = startRow + 1

        for _, entry in ipairs(list) do
            if row >= math.floor(screenHeight / 2) then break end

            local text = string.format("%d/%d %s", entry.provided, entry.needed, entry.name)
            local job = entry.profession and (" - " .. entry.profession) or ""
            mon.setCursorPos(2, row)
            mon.setTextColor(entry.color)
            mon.write(text:sub(1, 40))
            row = row + 1

            mon.setCursorPos(2, row)
            mon.setTextColor(colors.gray)
            mon.write(job:sub(1, 40))
            row = row + 1
        end

        return row
    end

    local row = drawSection("Equipment Requests", equipment_list, 2)
    row = drawSection("Builder Requests", builder_list, row + 1)
    drawSection("Nonbuilder Requests", nonbuilder_list, row + 1)
end

return workhandler
