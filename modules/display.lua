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

-- NEW: Draw table headers from a list of {x, label}
function display.drawTableHeaders(mon, y, columns)
    mon.setTextColor(colors.lightGray)
    for _, col in ipairs(columns) do
        mon.setCursorPos(col.x, y)
        mon.write(col.label)
    end
end

-- NEW: Draw horizontal line across screen
function display.drawHorizontalLine(mon, y)
    local w = mon.getSize()
    mon.setCursorPos(1, y)
    mon.setTextColor(colors.gray)
    mon.write(string.rep("-", w))
end

return display
