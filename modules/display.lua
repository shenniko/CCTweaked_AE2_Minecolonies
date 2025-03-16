-- Version: 1.0
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

return display
