-- display.lua
-- Utility functions for monitor-based drawing:
-- centered, left, right text, and border boxes.

local display = {}

-- Draw a row of text with left, center, or right justification
function display.mPrintRowJustified(mon, y, pos, text, fg, bg)
    local w = mon.getSize()
    local x = 1

    -- Calculate x position based on justification type
    if pos == "center" then
        x = math.floor((w - #text) / 2)
    elseif pos == "right" then
        x = w - #text + 1
    end

    -- Set optional text and background color
    if fg then mon.setTextColor(fg) end
    if bg then mon.setBackgroundColor(bg) end

    -- Print the text
    mon.setCursorPos(x, y)
    mon.write(text)

    -- Reset to defaults
    mon.setTextColor(colors.white)
    mon.setBackgroundColor(colors.black)
end

-- Draw a box with optional title at the top
function display.drawBox(mon, x1, y1, x2, y2, title)
    mon.setTextColor(colors.yellow)

    -- Draw horizontal borders
    for x = x1, x2 do
        mon.setCursorPos(x, y1) mon.write("-")
        mon.setCursorPos(x, y2) mon.write("-")
    end

    -- Draw vertical borders
    for y = y1, y2 do
        mon.setCursorPos(x1, y) mon.write("|")
        mon.setCursorPos(x2, y) mon.write("|")
    end

    -- Draw corners
    mon.setCursorPos(x1, y1) mon.write("+")
    mon.setCursorPos(x2, y1) mon.write("+")
    mon.setCursorPos(x1, y2) mon.write("+")
    mon.setCursorPos(x2, y2) mon.write("+")

    -- Optional centered title in top border
    if title then
        mon.setCursorPos(math.floor((x1 + x2 - #title) / 2), y1)
        mon.write(title)
    end

    mon.setTextColor(colors.white)
end

return display
