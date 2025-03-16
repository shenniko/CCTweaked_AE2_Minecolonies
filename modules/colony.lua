-- colony.lua
-- Functions for interacting with the colonyIntegrator peripheral
-- Handles colonist status and construction/building info

local colony = {}

-- Get basic status of all citizens
-- Returns a table of { name, health, hunger, happiness, profession }
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


-- Get status of all builder buildings
-- Returns a table of { name, status }
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

-- Get name from target string (e.g., last 2 words)
-- e.g., "Builder Hut 1" -> "Hut 1"
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
