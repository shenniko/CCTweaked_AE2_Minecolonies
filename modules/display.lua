-- Version: 1.1
-- display.lua - Monitor display utilities + UI box drawing

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

-- Draw solid border box with optional label
function display.drawBox(mon, x1, y1, x2, y2, label, color)
    color = color or colors.gray
    paintutils.drawLine(x1, y1, x2, y1, color) -- Top
    paintutils.drawLine(x1, y2, x2, y2, color) -- Bottom
    paintutils.drawLine(x1, y1, x1, y2, color) -- Left
    paintutils.drawLine(x2, y1, x2, y2, color) -- Right

    if label then
        mon.setCursorPos(x1 + 2, y1)
        mon.setTextColor(colors.white)
        mon.setBackgroundColor(color)
        mon.write(" " .. label .. " ")
    end
end

-- Horizontal Line
function display.drawLineH(mon, y, x1, x2, color)
    color = color or colors.gray
    paintutils.drawLine(x1, y, x2, y, color)
end

-- Vertical Line
function display.drawLineV(mon, x, y1, y2, color)
    color = color or colors.gray
    paintutils.drawLine(x, y1, x, y2, color)
end

-- Fill a rectangular box with background color
function display.fillBox(mon, x1, y1, x2, y2, bgColor)
    for y = y1, y2 do
        mon.setCursorPos(x1, y)
        mon.setBackgroundColor(bgColor)
        mon.write(string.rep(" ", x2 - x1 + 1))
    end
    mon.setBackgroundColor(colors.black)
end

return display
