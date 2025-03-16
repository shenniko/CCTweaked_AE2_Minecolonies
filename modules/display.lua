-- Version: 1.2
-- display.lua - Monitor display utilities for bordered UI

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

-- Draws a box with a title, using filled paint-style blocks
function display.drawTitledBox(mon, x1, y1, x2, y2, title, borderColor, fillColor, titleColor)
    titleColor = titleColor or colors.white
    borderColor = borderColor or colors.gray
    fillColor = fillColor or colors.black

    -- Fill inside
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1 + 1, y)
        mon.setBackgroundColor(fillColor)
        mon.write(string.rep(" ", x2 - x1 - 1))
    end

    -- Top and bottom borders
    mon.setBackgroundColor(borderColor)
    mon.setCursorPos(x1, y1)
    mon.write(string.rep(" ", x2 - x1 + 1))
    mon.setCursorPos(x1, y2)
    mon.write(string.rep(" ", x2 - x1 + 1))

    -- Left/right borders
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, y)
        mon.write(" ")
        mon.setCursorPos(x2, y)
        mon.write(" ")
    end

    -- Overlay the title
    local titleX = math.floor((x1 + x2 - #title) / 2)
    mon.setCursorPos(titleX, y1)
    mon.setBackgroundColor(fillColor)
    mon.setTextColor(titleColor)
    mon.write(title)

    -- Reset
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
end

return display
