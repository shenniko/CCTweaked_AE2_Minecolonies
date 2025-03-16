-- Version: 1.1
-- display.lua - Monitor display utilities

local display = {}

function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2)
    mon.setCursorPos(x, 1)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- Draw a horizontal line with optional fallback
function display.drawHorizontalLine(mon, y, color)
    local w, _ = mon.getSize()
    local success = pcall(function()
        paintutils.drawLine(1, y, w, y, color or colors.gray)
    end)
    if not success then
        mon.setCursorPos(1, y)
        mon.setTextColor(color or colors.gray)
        mon.write(string.rep("-", w))
    end
end

-- Optional: For requests, draw column headers
function display.drawTableHeaders(mon, row, columns)
    mon.setTextColor(colors.lightGray)
    for _, col in ipairs(columns) do
        mon.setCursorPos(col.x, row)
        mon.write(col.label)
    end
end

return display
