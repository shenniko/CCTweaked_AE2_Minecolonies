-- Version: 1.2
-- display.lua - Display utilities for boxed UI components

local display = {}

-- Clear monitor and reset state
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Centered header text (no border)
function display.printHeader(mon, text)
    local w, _ = mon.getSize()
    local x = math.floor((w - #text) / 2) + 1
    mon.setCursorPos(x, 1)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

-- Print single line of text at Y (optional color)
function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- Draw a filled box (used for border-style UI)
function display.drawBox(mon, x1, y1, x2, y2, color)
    local width = x2 - x1 + 1
    local height = y2 - y1 + 1
    local line = string.rep(" ", width)

    mon.setBackgroundColor(color)
    for y = y1, y2 do
        mon.setCursorPos(x1, y)
        mon.write(line)
    end
end

-- Draw box with title (centered), fills border, inverse title
function display.drawBoxWithTitle(mon, x1, y1, x2, y2, title, borderColor)
    -- Draw full border box
    display.drawBox(mon, x1, y1, x2, y2, borderColor)

    -- Draw inverse title bar
    if title then
        local titleFull = " " .. title .. " "
        local titleX = math.floor((x2 + x1) / 2 - #titleFull / 2)
        mon.setCursorPos(titleX, y1)
        mon.setBackgroundColor(borderColor)
        mon.setTextColor(colors.black)
        mon.write(titleFull)
    end

    -- Reset cursor/bg
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
end

-- Draw simple horizontal line across monitor
function display.drawHorizontalLine(mon, y, color)
    local w, _ = mon.getSize()
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.gray)
    mon.write(string.rep("-", w))
end

-- Draw aligned column headers
function display.drawTableHeaders(mon, row, columns)
    mon.setTextColor(colors.lightGray)
    for _, col in ipairs(columns) do
        mon.setCursorPos(col.x, row)
        mon.write(col.label)
    end
end

return display
