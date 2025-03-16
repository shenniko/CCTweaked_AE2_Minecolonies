-- workhandler.lua
-- Handles colony requests + ME logic, with crash safety + profession display

local workhandler = {}

local logger = require("modules.logger")
local colonyUtil = require("modules.colony")
local display = require("modules.display")
local meutils = require("modules.meutils")
local filter = require("modules.requestFilter")

local function extractNameFromTarget(target)
    local words = {}
    for word in target:gmatch("%S+") do table.insert(words, word) end
    if #words >= 2 then
        return words[#words - 1] .. " " .. words[#words]
    end
    return target
end

local function getColonistJobByTarget(colonists, target)
    local name = extractNameFromTarget(target)
    for _, c in ipairs(colonists or {}) do
        if c.name == name then
            return c.job or target
        end
    end
    return target
end

function workhandler.scanAndDisplay(mon, colonyPeripheral, meBridge, storageSide, screenHeight, colonists)
    local builder_list = {}
    local nonbuilder_list = {}
    local equipment_list = {}

    local itemMap = meutils.getItemMap(meBridge)
    local workRequests = colonyPeripheral.getRequests()

    for _, request in ipairs(workRequests) do
        if request and request.items and request.items[1] and request.items[1].name then
            local itemName = request.items[1].name
            local target = colonyUtil.extractTargetName(request.target)
            local count = request.count or 1
            local provided = 0
            local color = colors.blue

            if filter.shouldSkip(request) then
                logger.add("[Skipped] " .. request.name .. " [" .. target .. "]", colors.gray)
                color = colors.gray
            else
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

            local entry = {
                name = request.name,
                item = itemName,
                target = target,
                needed = count,
                provided = provided,
                color = color
            }

            if request.desc and request.desc:find("of class") then
                table.insert(equipment_list, entry)
            elseif target:find("Builder") then
                table.insert(builder_list, entry)
            else
                table.insert(nonbuilder_list, entry)
            end
        else
            logger.add("[Skipped] Malformed request (missing item name)", colors.red)
        end

        -- 💤 Give server a breather between requests
        sleep(0.05)
    end

    -- === Render Work Request UI ===
    local row = 2
    mon.clear()
    display.mPrintRowJustified(mon, 1, "center", "MineColonies Work Requests", colors.white)

    local function printCategory(title, list)
        if #list > 0 then
            display.mPrintRowJustified(mon, row, "center", title, colors.lightBlue)
            row = row + 1
            for _, entry in ipairs(list) do
                local job = getColonistJobByTarget(colonists, entry.target)
                local nameWithJob = string.format("%s - %s", entry.name, job)
                local leftText = string.format("%d/%d %s", entry.provided, entry.needed, nameWithJob)
                local rightText = entry.target

                display.mPrintRowJustified(mon, row, "left", leftText:sub(1, 40), entry.color)
                display.mPrintRowJustified(mon, row, "right", rightText:sub(1, 20), entry.color)
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
