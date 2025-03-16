-- Version: 1.0
-- touchpoint.lua - Button-based monitor interaction (MIT Licensed)
-- Source adapted from Kasra-G/ReactorController (MIT)

local Touchpoint = {}
Touchpoint.__index = Touchpoint

function Touchpoint.new(monitor)
    local self = setmetatable({}, Touchpoint)
    self.monitor = monitor
    self.buttons = {}
    self.monW, self.monH = monitor.getSize()
    return self
end

-- Add a button
function Touchpoint:add(name, xMin, xMax, yMin, yMax, text, bgColor, fgColor)
    self.buttons[name] = {
        xMin = xMin,
        xMax = xMax,
        yMin = yMin,
        yMax = yMax,
        text = text,
        bg = bgColor or colors.gray,
        fg = fgColor or colors.white,
    }
end

-- Draw all buttons
function Touchpoint:draw()
    for _, btn in pairs(self.buttons) do
        for y = btn.yMin, btn.yMax do
            self.monitor.setCursorPos(btn.xMin, y)
            self.monitor.setBackgroundColor(btn.bg)
            self.monitor.setTextColor(btn.fg)
            local text = btn.text or ""
            local space = math.max(0, btn.xMax - btn.xMin + 1 - #text)
            local paddingLeft = math.floor(space / 2)
            local paddingRight = space - paddingLeft
            self.monitor.write(
                string.rep(" ", paddingLeft) ..
                text:sub(1, btn.xMax - btn.xMin + 1) ..
                string.rep(" ", paddingRight)
            )
        end
    end
    self.monitor.setBackgroundColor(colors.black)
    self.monitor.setTextColor(colors.white)
end

-- Handle a click event
function Touchpoint:click(x, y)
    for name, btn in pairs(self.buttons) do
        if x >= btn.xMin and x <= btn.xMax and y >= btn.yMin and y <= btn.yMax then
            return name
        end
    end
    return nil
end

return Touchpoint
