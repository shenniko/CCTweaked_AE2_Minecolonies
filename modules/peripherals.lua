-- Version: 1.0
-- peripherals.lua - Safe Peripheral Management Layer

local peripherals = {}
local config = require("modules.config")

-- Monitor wrappers
function peripherals.getMainMonitor()
    return peripheral.wrap(config.MONITOR_MAIN)
end

function peripherals.getDebugMonitor()
    return peripheral.wrap(config.MONITOR_DEBUG)
end

-- Dynamic safety-wrapped peripherals
function peripherals.getMEBridge()
    local success, bridge = pcall(function()
        return peripheral.find("meBridge")
    end)
    return success and bridge or nil
end

function peripherals.getColonyIntegrator()
    local success, colony = pcall(function()
        return peripheral.find("colonyIntegrator")
    end)
    return success and colony or nil
end

return peripherals
