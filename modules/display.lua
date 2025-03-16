-- Version: 1.3
-- display.lua - Display utilities with theme, headers, boxes, and menus

local display = {}

-- === Configurable Colors ===
local THEME = {
    border      = colors.lightBlue,
    titleBg     = colors.lightBlue,
    titleText   = colors.cyan,
    text        = colors.white,
    background  = colors.black,
    headerText  = colors.lightGray,
    menuTitle   = colors.cyan,
    menuText    = colors.lime,
    menuBg      = colors.black,
}

-- === Basic Utilities ===

function display.clear(mon)
    mon.setBackgroundColor(THEME.background)
    mon.clear()
    mon.setCursorPos(1, 1)
end

function display.printLine(mon, y, text, color)
    mon.setCursorPos(1, y)
    mon.setTextColor(color or THEME.text)
    mon.write(text)
end

function display.printHeader(mon, text)
    local w = mon.getSize()
    local x = math.floor((w - #text) / 2)
    mon.setCursorPos(x, 1)
    mon.setTextColor(THEME.titleText)
    mon.write(text)
end

-- === Box Drawing ===

function display.drawTitledBox(mon, x1, y1, x2, y2, title, fillColor)
    fillColor = fillColor or THEME.background

    -- Fill the interior
    for y = y1 + 1, y2 - 1 do
        mon.setCursorPos(x1 + 1, y)
        mon.setBackgroundColor(fillColor)
        mon.write(string.rep(" ", x2 - x1 - 1))
    end

    -- Draw borders
    mon.setBackgroundColor(THEME.border)
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

    -- Draw centered title inside top bar
    local titleX = math.floor((x1 + x2 - #title) / 2)
    mon.setCursorPos(titleX, y1)
    mon.setBackgroundColor(THEME.titleBg)
    mon.setTextColor(THEME.titleText)
    mon.write(title)

    -- Reset
    mon.setTextColor(THEME.text)
    mon.setBackgroundColor(THEME.background)
end

-- === Header Row ===

function display.drawHeaderRow(mon, rowY, columns)
    mon.setTextColor(THEME.headerText)
    for _, col in ipairs(columns) do
        mon.setCursorPos(col.x, rowY)
        mon.write(col.label)
    end
end

-- === Menu Drawing ===

function display.drawMenu(mon, title, x1, y1, x2, y2, items)
    display.drawTitledBox(mon, x1, y1, x2, y2, title, THEME.menuBg)

    mon.setTextColor(THEME.menuText)
    local row = y1 + 2
    for _, item in ipairs(items) do
        if row >= y2 then break end
        mon.setCursorPos(x1 + 2, row)
        mon.write(item)
        row = row + 1
    end
end

return display
