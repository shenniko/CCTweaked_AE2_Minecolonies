-- Version: 1.4
-- display.lua - Monitor rendering utilities (panels, boxes, text, etc.)

local display = {}

-- Clear the screen
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Print a centered title at the top
function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2)
    mon.setCursorPos(x, 1)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

-- Print text on specific row (left-aligned)
function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- 🟦 Draw a border box (no fill)
function display.drawBox(mon, x1, y1, x2, y2, color)
    mon.setBackgroundColor(color or colors.gray)

    -- Top & bottom borders
    local horizLine = string.rep(" ", x2 - x1 + 1)
    mon.setCursorPos(x1, y1)
    mon.write(horizLine)
    mon.setCursorPos(x1, y2)
    mon.write(horizLine)

    -- Vertical borders
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, y)
        mon.write(" ")
        mon.setCursorPos(x2, y)
        mon.write(" ")
    end

    mon.setBackgroundColor(colors.black)
end

-- 🟨 Draw filled box with border
function display.drawFilledBox(mon, x1, y1, x2, y2, borderColor, fillColor)
    display.drawBox(mon, x1, y1, x2, y2, borderColor)

    -- Fill interior
    mon.setBackgroundColor(fillColor or colors.black)
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1 + 1, y)
        mon.write(string.rep(" ", (x2 - x1 - 1)))
    end

    mon.setBackgroundColor(colors.black)
end

-- 📝 Draw text with color, background, and positioning
function display.drawText(mon, x, y, text, textColor, bgColor)
    local px, py = mon.getCursorPos()
    mon.setCursorPos(x, y)
    mon.setTextColor(textColor or colors.white)
    mon.setBackgroundColor(bgColor or colors.black)
    mon.write(text)
    mon.setTextColor(colors.white)
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(px, py)
end

-- 📦 Draw a titled panel (filled box with centered title)
function display.drawTitledBox(mon, x1, y1, x2, y2, title, borderColor, fillColor, titleColor)
    display.drawFilledBox(mon, x1, y1, x2, y2, borderColor, fillColor)
    if title then
        local width = x2 - x1 + 1
        local titleX = x1 + math.floor((width - #title) / 2)
        display.drawText(mon, titleX, y1, title, titleColor or colors.white, borderColor)
    end
end

return display
