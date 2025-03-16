-- peripherals.lua - Safe Peripheral Management

local peripherals = {}

-- Wrapper to safely find a peripheral every time
local function safeFind(peripheralType)
    local success, result = pcall(function() return peripheral.find(peripheralType) end)
    return success and result or nil
end

-- Gets peripherals dynamically
function peripherals.getMEBridge() return safeFind("meBridge") end
function peripherals.getColonyIntegrator() return safeFind("colonyIntegrator") end
function peripherals.getMonitor(name) return peripheral.wrap(name) end

-- Checks if a peripheral is available
function peripherals.isValid(peripheralObj)
    return peripheralObj ~= nil
end

return peripherals
