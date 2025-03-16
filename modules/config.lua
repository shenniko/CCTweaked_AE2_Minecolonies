-- Version: 1.1
-- config.lua
-- Central config for all tweakable settings

local config = {
    -- Peripheral names
    MONITOR_MAIN = "monitor_4",
    MONITOR_DEBUG = "monitor_6",
    ME_STORAGE_SIDE = "bottom",

    -- Scan interval (seconds between checks)
    TIME_BETWEEN_SCANS = 30,

    -- Maximum debug log entries
    DEBUG_LOG_LIMIT = 100,

    -- Text scale
    TEXT_SCALE = 0.5
}

-- Tool / Sword material limits by work hut level
config.toolLevels = {
    [0] = "wood",
    [1] = "stone",
    [2] = "iron",
    [3] = "diamond",
    [4] = "netherite",
    [5] = "all"
}

-- Armor material limits by guard tower level
config.armorLevels = {
    [1] = "leather",
    [2] = "chainmail",
    [3] = "iron",
    [4] = "diamond",
    [5] = "all"
}

-- (Optional) Bow / Fishing rod support – not used yet
config.bowLevels = {
    [0] = "none",
    [1] = "none",
    [2] = "basic",
    [3] = "basic",
    [4] = "basic",
    [5] = "all"
}

return config
