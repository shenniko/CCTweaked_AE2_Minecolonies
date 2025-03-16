-- Version: 1.1
-- display.lua - Monitor display utilities with enhanced box styling

local display = {}

-- Clear screen
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Print centered header text
function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2)
    mon.setCursorPos(x, 1)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

-- Print a line of text at a specific row with a color
function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- Draw a full bordered box with a centered title
function display.drawFancyBox(mon, x1, y1, x2, y2, title, borderColor)
    borderColor = borderColor or colors.gray

    -- Top border with title
    local width = x2 - x1 + 1
    local filler = "═"
    local leftCorner = "╔"
    local rightCorner = "╗"

    local sideSpace = math.floor((width - #title - 2) / 2)
    local titleLine = leftCorner
        .. string.rep(filler, sideSpace)
        .. " " .. title .. " "
        .. string.rep(filler, width - #title - 2 - sideSpace)
        .. rightCorner

    mon.setCursorPos(x1, y1)
    mon.setTextColor(colors.cyan)
    mon.write(titleLine)

    -- Vertical sides
    for i = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, i)
        mon.setTextColor(borderColor)
        mon.write("║")
        mon.setCursorPos(x2, i)
        mon.write("║")
    end

    -- Bottom border
    mon.setCursorPos(x1, y2)
    mon.write("╚" .. string.rep("═", width - 2) .. "╝")
end

return display
