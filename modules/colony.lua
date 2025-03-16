-- Version: 1.14
-- colony.lua - Handles data gathering from the colony peripheral

local colony = {}

-- Get all citizens with relevant info
function colony.getColonyStatus(colonyPeripheral)
    local list = {}

    if not colonyPeripheral then return list end

    for _, c in ipairs(colonyPeripheral.getCitizens()) do
        table.insert(list, {
            name = c.name,
            health = c.health,
            saturation = c.saturation,
            happiness = c.happiness,
            job = c.job and c.job.name or "Unemployed",
            work = c.work
        })
    end

    return list
end

-- Get builder task display using citizen work and matching to buildings
function colony.getConstructionStatus(colonyPeripheral)
    local result = {}

    if not colonyPeripheral then return result end

    local buildings = colonyPeripheral.getBuildings()
    local buildingMap = {}

    -- Build a quick lookup by location
    for _, b in ipairs(buildings) do
        if b.location then
            local key = string.format("%d,%d,%d", b.location.x, b.location.y, b.location.z)
            buildingMap[key] = b
        end
    end

    local citizens = colonyPeripheral.getCitizens()

    for _, c in ipairs(citizens) do
        if c.job and c.job.name == "Builder" then
            local builderName = c.name
            local work = c.work or {}
            local action = work.description or work.job or "Idle"
            local step = work.step and (" [Step " .. work.step .. "]") or ""
            local level = work.level or ""

            local buildingName = "Unknown"
            if work.location then
                local key = string.format("%d,%d,%d", work.location.x, work.location.y, work.location.z)
                local b = buildingMap[key]
                if b then
                    -- Clean the name for display
                    buildingName = b.name
                        :gsub("^.*colonies%.", "")
                        :gsub("^.*building%.", "")
                        :gsub("^.*minecolonies%.", "")
                        :gsub("[^%w_]", " ")
                        :gsub("_", " ")
                        :gsub("^%s+", "")
                        :gsub("%s+$", "")
                end
            end

            local line = string.format("%s - %s %s%s", builderName, action, buildingName, step)

            table.insert(result, {
                name = builderName,
                target = line,
                progress = 0,
                built = false,
                extra = ""
            })
        end
    end

    return result
end

-- Used in workhandler to simplify request target
function colony.extractTargetName(target)
    local words = {}
    for word in target:gmatch("%S+") do
        table.insert(words, word)
    end
    if #words >= 2 then
        return words[#words - 1] .. " " .. words[#words]
    end
    return target
end

return colony
