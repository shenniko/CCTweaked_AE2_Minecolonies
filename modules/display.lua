-- Version: 1.4
-- display.lua - Monitor display utilities and fancy box drawing

local display = {}

-- Clears the monitor
function display.clear(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1, 1)
end

-- Centered header text
function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2) + 1
    mon.setCursorPos(x, 1)
    mon.setTextColor(colors.cyan)
    mon.write(text)
end

-- Print line of text at y
function display.printLine(mon, y, text, color)
    mon.setCursorPos(2, y)
    mon.setTextColor(color or colors.white)
    mon.write(text)
end

-- Draw a horizontal line
function display.drawHorizontalLine(mon, y, color)
    local w = mon.getSize()
    mon.setCursorPos(1, y)
    mon.setTextColor(color or colors.gray)
    mon.write(string.rep("-", w))
end

-- Draw table headers given column positions
function display.drawTableHeaders(mon, row, columns)
    mon.setTextColor(colors.lightGray)
    for _, col in ipairs(columns) do
        mon.setCursorPos(col.x, row)
        mon.write(col.label)
    end
end

-- Fancy bordered box with title text
function display.drawFancyBox(mon, x1, y1, x2, y2, title, borderColor)
    borderColor = borderColor or colors.gray
    local oldBg = mon.getBackgroundColor()
    local oldText = mon.getTextColor()

    mon.setTextColor(borderColor)

    -- Corners
    mon.setCursorPos(x1, y1) mon.write("+")
    mon.setCursorPos(x2, y1) mon.write("+")
    mon.setCursorPos(x1, y2) mon.write("+")
    mon.setCursorPos(x2, y2) mon.write("+")

    -- Top & Bottom
    for x = x1 + 1, x2 - 1 do
        mon.setCursorPos(x, y1) mon.write("-")
        mon.setCursorPos(x, y2) mon.write("-")
    end

    -- Sides
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1, y) mon.write("|")
        mon.setCursorPos(x2, y) mon.write("|")
    end

    -- Title overlay
    if title then
        local mid = math.floor((x1 + x2) / 2)
        local start = mid - math.floor(#title / 2)
        if start > x1 and (start + #title) < x2 then
            mon.setCursorPos(start - 2, y1)
            mon.write("[" .. title .. "]")
        end
    end

    mon.setTextColor(oldText)
    mon.setBackgroundColor(oldBg)
end

return display
