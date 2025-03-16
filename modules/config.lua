-- Version: 1.0
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

return config
