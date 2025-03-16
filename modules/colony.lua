-- Version: 1.17
-- colony.lua - Handles data gathering from the colony peripheral

local colony = {}

-- Utility: Clean internal MineColonies names into display-friendly ones
local function cleanName(str)
    return str
        :gsub("^.*colonies%.", "")
        :gsub("^.*building%.", "")
        :gsub("^.*minecolonies%.", "")
        :gsub("^.*job%.", "")
        :gsub("_", " ")
        :gsub("%.", " ")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

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
            job = (c.work and cleanName(c.work.name))
                or (c.job and cleanName(c.job.name))
                or "Unemployed",
            work = c.work
        })
    end

    return list
end

-- Get construction status by scanning citizens working in builder-type roles
function colony.getConstructionStatus(colonyPeripheral)
    local result = {}

    if not colonyPeripheral then return result end

    local citizens = colonyPeripheral.getCitizens()

    for _, c in ipairs(citizens) do
        if c.work and c.work.type == "builder" then
            local builderName = c.name
            local work = c.work
            local buildingName = cleanName(work.name or "Unknown")
            local rawTask = work.description or work.job or "Working"
            local task = cleanName(rawTask)

            -- Prevent duplicate builder name in task
            if task == builderName then
                task = "builder"
            end

            local step = work.step and (" [Step " .. work.step .. "]") or ""
            local level = work.level and (" (Level " .. work.level .. ")") or ""

            local line = string.format("%s - %s at %s%s%s",
                builderName, task, buildingName, level, step)

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
