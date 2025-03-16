-- Version: 1.11
-- workhandler.lua - Handles MineColonies work requests and ME interactions

local meutils = require("modules.meutils")
local requestFilter = require("modules.requestFilter")
local colonyUtil = require("modules.colony")
local logger = require("modules.logger")

local workhandler = {}

-- Main scan and render logic
function workhandler.scanAndDisplay(mon, storageSide, screenHeight, colonists)
    local builder_list = {}
    local nonbuilder_list = {}
    local equipment_list = {}

    -- Get work requests
    local colony = peripheral.find("colonyIntegrator")
    if not colony then
        logger.log("Colony Integrator not found!", colors.red)
        return
    end

    local requests = colony.getRequests()
    if not requests then return end

    for _, req in ipairs(requests) do
        local item = req.items[1]
        local itemName = item.name
        local needed = req.count
        local provided = 0
        local desc = req.desc
        local target = colonyUtil.extractTargetName(req.target or "")
        local requester = req.target or ""
        local displayColor = colors.blue

        -- Determine request category
        local isEquipment = desc:find("Tool of class") or requestFilter.isEquipment(req.name)
        local isBuilder = target:lower():find("builder")

        -- Should we use ME system?
        local useME = not requestFilter.shouldSkipItem(req.name)

        if useME then
            local canExport, available = meutils.canExport(itemName)

            if canExport then
                -- Attempt export
                local success = pcall(function()
                    provided = peripheral.call(storageSide, "pullItem", {
                        name = itemName,
                        count = needed,
                        direction = storageSide
                    })
                end)
                if provided and provided >= needed then
                    displayColor = colors.lime
                    logger.log("[Provided] " .. needed .. " x " .. itemName, colors.lime)
                else
                    -- Try crafting
                    if meutils.isCrafting(itemName) then
                        displayColor = colors.yellow
                        logger.log("[Crafting] " .. itemName, colors.yellow)
                    elseif peripheral.call(peripheral.find("meBridge"), "craftItem", { name = itemName, count = needed }) then
                        displayColor = colors.orange
                        logger.log("[Scheduled] " .. needed .. " x " .. itemName, colors.orange)
                    else
                        displayColor = colors.red
                        logger.log("[Failed] " .. itemName, colors.red)
                    end
                end
            else
                displayColor = colors.red
                logger.log("[Missing] " .. itemName, colors.red)
            end
        else
            displayColor = colors.gray
            logger.log("[Skipped] " .. req.name .. " [" .. target .. "]", colors.gray)
        end

        -- Determine job/profession
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
            requester = requester,
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

    -- Draw top section
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
