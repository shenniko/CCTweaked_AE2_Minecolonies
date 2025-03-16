-- Version: 1.1
-- display.lua - Monitor display utilities

local display = {}

-- Clear screen with black background
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Centered cyan title
function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2)
    mon.setCursorPos(x, 1)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

-- Simple text at y
function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.setBackgroundColor(colors.black)
    mon.write(text)
end

-- Draw a solid border box with a title
function display.drawBoxWithTitle(mon, x1, y1, x2, y2, title, borderColor)
    -- Top and bottom
    paintutils.drawLine(x1, y1, x2, y1, borderColor)
    paintutils.drawLine(x1, y2, x2, y2, borderColor)

    -- Left and right
    paintutils.drawLine(x1, y1, x1, y2, borderColor)
    paintutils.drawLine(x2, y1, x2, y2, borderColor)

    -- Fill title background
    local titleX = math.floor((x1 + x2) / 2 - (#title / 2))
    mon.setBackgroundColor(borderColor)
    mon.setCursorPos(titleX, y1)
    mon.write((" "):rep(#title))
    mon.setCursorPos(titleX, y1)
    mon.setTextColor(colors.cyan)
    mon.write(title)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
end

return display
