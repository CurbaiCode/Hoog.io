--[[
 -- UI.lua
 -- DPEio Builder 0.2
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local UI = {}
local lvg = love.graphics
local lvm = love.mouse

-- CONSTANTS
UI.DEBUG = false
local outlineWidth = 4
local outlineRadius = 12
UI.font = lvg.newFont("Now-Bold.otf", 18) -- Font
UI.fontLarge = lvg.newFont("Now-Bold.otf", 22)

-- COLORS
function UI.newColor(r, g, b, a)
    return r / 255, g / 255, b / 255, (a or 1)
end

local function multiplyAlpha(c, a)
    return { c[1], c[2], c[3], c[4] * a }
end

UI.color = {
    red = { UI.newColor(255, 59, 48) },
    orange = { UI.newColor(255, 149, 0) },
    yellow = { UI.newColor(255, 204, 0) },
    green = { UI.newColor(40, 205, 65) },
    mint = { UI.newColor(0, 199, 190) },
    teal = { UI.newColor(89, 173, 196) },
    cyan = { UI.newColor(85, 190, 240) },
    blue = { UI.newColor(0, 122, 255) },
    indigo = { UI.newColor(88, 86, 214) },
    purple = { UI.newColor(175, 82, 222) },
    pink = { UI.newColor(255, 45, 85) },
    brown = { UI.newColor(162, 132, 94) },
    black = { UI.newColor(28, 28, 30) },
    white = { UI.newColor(242, 242, 247) },
    darkGray = { UI.newColor(142, 142, 147) },
    gray = { UI.newColor(174, 174, 178) },
    lightGray = { UI.newColor(199, 199, 204) },
    line = { UI.newColor(0, 0, 0, 0.5) },
    highlight = { UI.newColor(255, 255, 255, 0.25) },
    shadow = { UI.newColor(0, 0, 0, 0.33) },
    hover = { UI.newColor(255, 255, 255, 0.1) }
}

-- DRAWING FUCNTIONS
-- Text
function UI.text(t, f, x, y, w) -- ("text", size, x, y, width)
    x, y = (x or 0), (y or 0)
    w = w or 500
    f = f or UI.font
    local p = f == UI.font and 2 or 3
    y = y - (f:getHeight() / 2)
    lvg.push()
    lvg.translate(-w / 2, 0)
    lvg.setColor(UI.color.black)
    if not UI.DEBUG then
        lvg.printf(t, f, x, y - p, w, "center")     -- Top
        lvg.printf(t, f, x + p, y - p, w, "center") -- Top right
        lvg.printf(t, f, x + p, y, w, "center")     -- Right
        lvg.printf(t, f, x + p, y + p, w, "center") -- Bottom right
        lvg.printf(t, f, x, y + p, w, "center")     -- Bottom
        lvg.printf(t, f, x - p, y + p, w, "center") -- Bottom left
        lvg.printf(t, f, x - p, y, w, "center")     -- Left
        lvg.printf(t, f, x - p, y - p, w, "center") -- Top left
        lvg.setColor(UI.color.white)
    end
    lvg.printf(t, f, x, y, w, "center")
    lvg.pop()
end

-- Polygons
function UI.circle(x, y, r, c, w, t) -- (x, y, radius, color, outline width, transparency)
    t = t or 1
    lvg.setColor(multiplyAlpha(c, t))
    if not UI.DEBUG then
        lvg.circle("fill", x, y, r)
        lvg.setColor(multiplyAlpha(UI.color.line, t))
    end
    lvg.setLineWidth(w)
    lvg.circle("line", x, y, r - (w / 2))
end

function UI.rectangle(x, y, w, h, c, o, s, a, t, b) -- (x, y, width, height, color, outline width, outline radius, alignment, transparency, border)
    b = (b == nil) and true or b
    t = t or 1
    a = a or "none"
    if a == "vertical" or a == "both" then
        y = y - (h / 2)
    end
    if a == "horizontal" or a == "both" then
        x = x - (w / 2)
    end
    local l = s - (o / 2)
    lvg.setColor(multiplyAlpha(c, t))
    if not UI.DEBUG then
        lvg.rectangle("fill", x, y, w, h, s, s)
        lvg.setColor(multiplyAlpha(UI.color.line, t))
    end
    if b then
        lvg.setLineWidth(o)
        lvg.rectangle("line", x + (o / 2), y + (o / 2), w - o, h - o, l, l)
    end
end

UI.rect = UI.rectangle

function UI.trapeziod(x, y, w, h1, h2, c, o, t) -- (x, y, width, width, start height, end height, color, outlineWidth, transparency)
    t = t or 1
    lvg.setColor(multiplyAlpha(c, t))
    if not UI.DEBUG then
        lvg.polygon("fill", x, y - h1, x, y + h1, x + w, y + (h2 / 2), x + w, y + -(h2 / 2))
        lvg.setColor(multiplyAlpha(UI.color.line, t))
    end
    lvg.setLineWidth(o)
    lvg.polygon("line", x + (o / 2), y - (h1 - (o / 2)), x + (o / 2), y + (h1 - (o / 2)), x + w - (o / 2),
        y + (h2 / 2) - (o / 2), x + w - (o / 2), y + -(h2 / 2) + (o / 2))
end

function UI.ngon(s, x, y, n, r, c, o, t) -- (x, y, vertices, radius, color, outline width, transparency)
    t = t or 1
    local cr = s == "small" and r + (o / 2) or r / math.cos(math.pi / n)
    local v = {}
    for i = 0, n - 1 do
        local a = (i / n) * math.pi * 2
        table.insert(v, cr * math.cos(a) + x)
        table.insert(v, cr * math.sin(a) + y)
    end
    lvg.setColor(multiplyAlpha(c, t))
    if not UI.DEBUG then
        lvg.polygon("fill", v)
        lvg.setColor(multiplyAlpha(UI.color.line, t))
    end
    lvg.setLineWidth(o)
    cr = s == "small" and r or (r - (o / 2)) / math.cos(math.pi / n)
    v = {}
    for i = 0, n - 1 do
        local a = (i / n) * math.pi * 2
        table.insert(v, cr * math.cos(a) + x)
        table.insert(v, cr * math.sin(a) + y)
    end
    lvg.polygon("line", v)
end

function UI.stargon(s, x, y, n, r, c, o, t) -- (x, y, vertices, radius, color, outline width, transparency)
    t = t or 1
    local r1 = r + (4 * r / n / n)
    local r2 = r - (4 * r / n / n)
    local cr1 = s == "small" and r1 or r1 / math.cos(math.pi / n)
    local cr2 = s == "small" and r2 or r2 / math.cos(math.pi / n)
    local v = {}
    for i = 0, n - 1 do
        local a = (i / n) * math.pi * 2
        table.insert(v, cr2 * math.cos(a) + x)
        table.insert(v, cr2 * math.sin(a) + y)
        a = a + ((0.5 / n) * math.pi * 2)
        table.insert(v, cr1 * math.cos(a) + x)
        table.insert(v, cr1 * math.sin(a) + y)
    end
    lvg.setColor(multiplyAlpha(c, t))
    if not UI.DEBUG then
        lvg.polygon("fill", v)
        lvg.setColor(multiplyAlpha(UI.color.line, t))
    end
    lvg.setLineWidth(o)
    cr1 = s == "small" and r1 - (o / 2) or (r1 - (o / 2)) / math.cos(math.pi / n)
    cr2 = s == "small" and r2 - (o / 2) or (r2 - (o / 2)) / math.cos(math.pi / n)
    v = {}
    for i = 0, n - 1 do
        local a = (i / n) * math.pi * 2
        table.insert(v, cr2 * math.cos(a) + x)
        table.insert(v, cr2 * math.sin(a) + y)
        a = a + ((0.5 / n) * math.pi * 2)
        table.insert(v, cr1 * math.cos(a) + x)
        table.insert(v, cr1 * math.sin(a) + y)
    end
    lvg.polygon("line", v)
end

-- BUTTON
UI.buttons = {}
UI.Button = class("Button")
function UI.Button:init(text, color, x, y, alignment, font)
    self.text = text
    self.font = font or UI.font
    self.x = x or 0
    self.y = y or 0
    self.alignment = alignment or "both"
    self.width = self.font:getWidth(self.text) + (outlineWidth * 2) + 32
    self.height = self.font:getHeight(self.text) + (outlineWidth * 2) + 16
    self.color = color or UI.color.darkGray
    self.xOffset = 0
    self.yOffset = 0
    self.hovered = false
    self.pressed = false

    table.insert(UI.buttons, self)
end

function UI.Button:draw()
    UI.rect(self.x, self.y, self.width, self.height, self.color, outlineWidth, outlineRadius, self.alignment)
    if self.hovered then
        UI.rect(self.x, self.y, self.width, self.height, UI.color.hover, outlineWidth, outlineRadius, self.alignment, 1,
            false)
    end
    UI.text(self.text, self.font, self.x, self.y, self.width)
    UI.rect(self.x, self.y, self.width - (outlineWidth * 2), (self.height - (outlineWidth * 2)) / 2,
        self.pressed and UI.color.shadow or UI.color.highlight, outlineWidth, outlineRadius - outlineWidth,
        self.alignment, 1, false)
end

function UI.Button:contains(x, y)
    if x > ((self.x + self.xOffset) - (self.width / 2)) and x < (self.x + self.xOffset) + (self.width / 2) and y > (self.y + self.yOffset) - (self.height / 2) and y < (self.y + self.yOffset) + (self.height / 2) then
        return true
    end
    return false
end

-- MOUSE FUNCTIONS
function UI.mousemoved(x, y)
    UI.mouseoverbutton = false
    for _, b in ipairs(UI.buttons) do
        if b:contains(x, y) then
            UI.mouseoverbutton = true
            if not b.pressed then
                b.hovered = true
            end
        end
        if not b:contains(x, y) then
            b.hovered = false
        end
    end
    lvm.setCursor(lvm.getSystemCursor(UI.mouseoverbutton == true and "hand" or "arrow"))
end

return UI
