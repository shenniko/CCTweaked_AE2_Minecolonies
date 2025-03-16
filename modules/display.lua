-- Version: 1.1
-- display.lua - Monitor display utilities with box drawing

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
    mon.setTextColor(colors.white)
end

function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
    mon.setTextColor(colors.white)
end

-- Draw a simple border box with a title and black background under the title
function display.drawFancyBox(mon, x1, y1, x2, y2, title, borderColor)
    borderColor = borderColor or colors.gray
    mon.setTextColor(borderColor)

    -- Top
    mon.setCursorPos(x1, y1)
    mon.write("+" .. string.rep("-", x2 - x1 - 2) .. "+")

    -- Sides
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, y)
        mon.write("|")
        mon.setCursorPos(x2, y)
        mon.write("|")
    end

    -- Bottom
    mon.setCursorPos(x1, y2)
    mon.write("+" .. string.rep("-", x2 - x1 - 2) .. "+")

    -- Title with black background
    if title then
        local centered = math.floor((x1 + x2) / 2 - (#title / 2))
        mon.setCursorPos(centered, y1)
        mon.setBackgroundColor(colors.black)
        mon.setTextColor(colors.cyan)
        mon.write(title)
        mon.setTextColor(colors.white)
        mon.setBackgroundColor(colors.black)
    end
end

return display
