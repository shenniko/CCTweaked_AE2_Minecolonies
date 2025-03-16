-- colony.lua
-- Functions for interacting with the colonyIntegrator peripheral

local colony = {}

-- Get basic status of all citizens, including profession/job
function colony.getColonyStatus(colonyPeripheral)
    local list = {}
    for _, c in ipairs(colonyPeripheral.getCitizens()) do
        table.insert(list, {
            name = c.name,
            health = c.health,
            hunger = c.saturation,
            happiness = c.happiness,
            job = c.job and c.job.name or "Unemployed"
        })
    end
    return list
end

-- Get all builder-related building progress
function colony.getConstructionStatus(colonyPeripheral)
    local result = {}
    for _, b in ipairs(colonyPeripheral.getBuildings()) do
        if b.type == "builder" then
            table.insert(result, {
                name = b.name,
                status = b.progress or "In Progress"
            })
        end
    end
    return result
end

-- Extract colonist's name from target string (last 2 words)
function colony.extractTargetName(target)
    local words = {}
    for word in target:gmatch("%S+") do
        table.insert(words, word)
    end
    if #words >= 2 then
        return words[#words - 1] .. " " .. words[#words]
    else
        return target
    end
end

return colony
