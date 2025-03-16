-- Version: 1.1
-- display.lua - Monitor display utilities

local display = {}

-- Clear monitor
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Print a centered header with black background
function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2) + 1
    mon.setCursorPos(x, 1)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.cyan)
    mon.write(text)
    mon.setTextColor(colors.white)
end

-- Print any line of text at Y
function display.printLine(mon, y, text, color)
    mon.setCursorPos(2, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- Draw a clean outer box using paintutils
function display.drawBox(mon, x1, y1, x2, y2, color)
    color = color or colors.gray
    mon.setBackgroundColor(color)

    -- Top and bottom
    paintutils.drawLine(x1, y1, x2, y1, color)
    paintutils.drawLine(x1, y2, x2, y2, color)

    -- Sides
    paintutils.drawLine(x1, y1, x1, y2, color)
    paintutils.drawLine(x2, y1, x2, y2, color)

    mon.setBackgroundColor(colors.black)
end

-- Draw a bordered title box (fancy)
function display.drawFancyBox(mon, x1, y1, x2, y2, title, color)
    display.drawBox(mon, x1, y1, x2, y2, color)

    -- Overlay title after box is drawn
    display.printHeader(mon, title)
end

return display
