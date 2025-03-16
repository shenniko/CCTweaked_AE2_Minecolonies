-- Version: 1.11
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
            job = c.job and c.job.name or "Unemployed"
        })
    end

    return list
end

-- Get detailed builder hut construction progress
function colony.getConstructionStatus(colonyPeripheral)
    local result = {}

    if not colonyPeripheral then return result end

    local buildings = colonyPeripheral.getBuildings()

    for _, b in ipairs(buildings) do
        if b.type == "builder" then
            local builderName = b.name:match("[^:]+$") or "Builder"
            local target = b.building or b.buildingName or b.currentBuilding or "Unknown"
            local progress = b.progress or 0

            table.insert(result, {
                name = builderName,
                target = target,
                progress = progress,
                built = b.built or false
            })
        end
    end

    return result
end

-- Helper: extract simplified name from a string like "Builder T. Caster"
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
