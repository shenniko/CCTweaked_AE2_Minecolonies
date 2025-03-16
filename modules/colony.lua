-- Version: 1.0
-- colony.lua - Colony request and citizen helpers

local colony = {}

function colony.getWorkRequests(colonyPeripheral)
    if not colonyPeripheral or not colonyPeripheral.getRequests then return {} end

    local success, requests = pcall(colonyPeripheral.getRequests)
    if not success or not requests then return {} end

    return requests
end

return colony
