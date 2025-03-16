-- Version: 1.2
-- display.lua - Monitor display utilities

local display = {}

-- === Basic Utilities ===

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

-- === Box Drawing ===

function display.drawTitledBox(mon, x1, y1, x2, y2, title, borderColor, fillColor, titleColor)
    borderColor = borderColor or colors.gray
    fillColor = fillColor or colors.black
    titleColor = titleColor or colors.cyan

    -- Fill area
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1 + 1, y)
        mon.setBackgroundColor(fillColor)
        mon.write(string.rep(" ", x2 - x1 - 1))
    end

    -- Borders
    mon.setBackgroundColor(borderColor)
    mon.setCursorPos(x1, y1)
    mon.write(string.rep(" ", x2 - x1 + 1))
    mon.setCursorPos(x1, y2)
    mon.write(string.rep(" ", x2 - x1 + 1))

    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, y)
        mon.write(" ")
        mon.setCursorPos(x2, y)
        mon.write(" ")
    end

    -- Title background fill
    mon.setCursorPos(x1 + 1, y1)
    mon.setBackgroundColor(borderColor)
    mon.write(string.rep(" ", x2 - x1 - 1))

    -- Title centered
    local titleX = math.floor((x1 + x2 - #title) / 2)
    mon.setCursorPos(titleX, y1)
    mon.setBackgroundColor(borderColor)
    mon.setTextColor(titleColor)
    mon.write(title)

    -- Reset
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
end

return display
