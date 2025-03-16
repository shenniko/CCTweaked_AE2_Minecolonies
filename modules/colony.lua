-- Version: 1.2
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
            work = c.work -- preserve for builder work check
        })
    end

    return list
end

-- Get construction status with builder task description
function colony.getConstructionStatus(colonyPeripheral)
    local result = {}

    if not colonyPeripheral then return result end

    local buildings = colonyPeripheral.getBuildings()
    local citizens = colonyPeripheral.getCitizens()

    for _, b in ipairs(buildings) do
        if b.type == "builder" then
            local builderName = b.name
                :gsub("^.*colonies%.", "")
                :gsub("^.*building%.", "")
                :gsub("^.*minecolonies%.", "")
                :gsub("[^%w_]", " ")
                :gsub("_", " ")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

            local taskDescription = "Idle"
            local progressText = ""

            -- Try to find the assigned builder citizen
            for _, c in ipairs(citizens) do
                if c.job and c.job.location and b.location then
                    if c.job.location.x == b.location.x and
                       c.job.location.y == b.location.y and
                       c.job.location.z == b.location.z then

                        if c.work and c.work.description then
                            taskDescription = c.work.description
                            if c.work.step then
                                progressText = string.format(" [Step %s]", c.work.step)
                            end
                        end
                    end
                end
            end

            table.insert(result, {
                name = builderName,
                target = taskDescription,
                progress = b.progress or 0,
                built = b.built or false,
                extra = progressText
            })
        end
    end

    return result
end

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
