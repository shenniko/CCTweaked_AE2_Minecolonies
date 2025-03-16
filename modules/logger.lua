-- Version: 1.0
-- logger.lua
-- Handles debug log storage, scrolling, and rendering to a monitor.

local logger = {
    log = {},           -- Stores log entries
    scroll_offset = 0,  -- For scroll support (future feature)
    max_entries = require("modules.config").DEBUG_LOG_LIMIT   -- Max log entries to keep in memory
}

-- Add a new entry to the log
-- @param msg: string to display
-- @param color: optional text color (default: white)
function logger.add(msg, color)
    table.insert(logger.log, {
        text = msg,
        color = color or colors.white
    })

    -- Keep log within size limit
    if #logger.log > logger.max_entries then
        table.remove(logger.log, 1)
    end
end

-- Draw the current log list to the given monitor
-- Includes a border box with a title
function logger.draw(mon)
    local display = require("modules.display")
    local w, h = mon.getSize()
    mon.clear()

    -- Draw log box frame
    display.drawBox(mon, 1, 1, w, h, " Debug Log ")

    -- Determine which part of the log to display
    local start = math.max(1, #logger.log - h + 2 - logger.scroll_offset)
    local row = 2

    -- Render visible log entries
    for i = start, math.min(#logger.log, start + h - 2) do
        local log = logger.log[i]
        mon.setCursorPos(2, row)
        mon.setTextColor(log.color)
        mon.write(log.text:sub(1, w - 2))
        row = row + 1
    end

    mon.setTextColor(colors.white)
end

return logger
