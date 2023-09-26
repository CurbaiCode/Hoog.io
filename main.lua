--[[
 -- DPEio Builder 0.1
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local lvg = love.graphics
local lvm = love.mouse

-- CONSTANTS
local DEBUG = false
local windowW, windowH = lvg.getDimensions()
local level = 45                               -- Player level
local scale = 0.25                             -- Zoom scale
local size = (1 + ((level - 1) / 100)) * scale -- Player size
local radius = 100                             -- Relative player size
local lineW = 16 * scale                       -- Outline Width
local shapeR = lineW                           -- Border radius
local lineR = shapeR - (lineW / 2)             -- Outline border radius
local uiW = 4                                  -- UI outline width
local uiR = 12                                 -- UI Radius
local uiFont = lvg.newFont("Now-Bold.otf", 18) -- Font
local uiFontL = lvg.newFont("Now-Bold.otf", 22)

-- FUNCTIONS
local function normalizeColor(r, g, b, a)
    return r / 255, g / 255, b / 255, (a or 1)
end

local color = {
    red = { normalizeColor(255, 59, 48) },
    orange = { normalizeColor(255, 149, 0) },
    yellow = { normalizeColor(255, 204, 0) },
    green = { normalizeColor(40, 205, 65) },
    mint = { normalizeColor(0, 199, 190) },
    teal = { normalizeColor(89, 173, 196) },
    cyan = { normalizeColor(85, 190, 240) },
    blue = { normalizeColor(0, 122, 255) },
    indigo = { normalizeColor(88, 86, 214) },
    purple = { normalizeColor(175, 82, 222) },
    pink = { normalizeColor(255, 45, 85) },
    brown = { normalizeColor(162, 132, 94) },
    black = { normalizeColor(28, 28, 30) },
    white = { normalizeColor(242, 242, 247) },
    darkGray = { normalizeColor(142, 142, 147) },
    gray = { normalizeColor(174, 174, 178) },
    lightGray = { normalizeColor(199, 199, 204) },
    line = { normalizeColor(0, 0, 0, 0.5) },
    highlight = { normalizeColor(255, 255, 255, 0.25) },
    shadow = { normalizeColor(0, 0, 0, 0.33) },
    hover = { normalizeColor(255, 255, 255, 0.1) }
}

-- Convert between radians and degrees
local function degToRad(d)
    return d * math.pi / 180
end

local function radToDeg(r)
    return r * 180 / math.pi
end

-- Interpolation function
local function lerp(v1, v2, a)
    return (v1 * (1 - a)) + (v2 * a)
end

-- Check if table contains value
local function hasValue(t, v)
    for _, u in ipairs(t) do
        if u == v then
            return true
        end
    end
    return false
end

-- Distribute points between a range that is centered on 0: e.g. if range is 200, values are between 100 and -100
local function centered(i, n, t) -- (index, number of items, total space or range)
    return i * (t / n) - ((t / n) * ((n + 1) / 2))
end

-- DRAWING FUNCTIONS
-- Polygons
local function drawCircle(x, y, r, c) -- (x, y, radius, color)
    lvg.setColor(c)
    if not DEBUG then
        lvg.circle("fill", x, y, r)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.circle("line", x, y, r - (lineW / 2))
end

local function drawSquare(x, y, r, c) -- (x, y, radius, color)
    lvg.setColor(c)
    if not DEBUG then
        lvg.rectangle("fill", x - r, y - r, r * 2, r * 2, shapeR, shapeR)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.rectangle("line", x - r + (lineW / 2), y - r + (lineW / 2), (r * 2) - lineW, (r * 2) - lineW, lineR, lineR)
end

local function drawPentagon(x, y, r, c) -- (x, y, radius, color)
    lvg.translate(x, y)
    local a1 = degToRad(18)
    local a2 = degToRad(54)
    local sa1 = math.sin(a1)
    local ca1 = math.cos(a1)
    local sa2 = math.sin(a2)
    local ca2 = math.cos(a2)
    lvg.setColor(c)
    if not DEBUG then
        lvg.polygon("fill", r, 0, r * sa1, r * ca1, -r * sa2, r * ca2, -r * sa2, -r * ca2, r * sa1, -r * ca1)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.polygon("line", r - (lineW / 2), 0, (r - (lineW / 2)) * sa1, (r - (lineW / 2)) * ca1, (-r + (lineW / 2)) * sa2,
        (r - (lineW / 2)) * ca2, (-r + (lineW / 2)) * sa2, (-r + (lineW / 2)) * ca2, (r - (lineW / 2)) * sa1,
        (-r + (lineW / 2)) * ca1)
end

local function drawRectangle(x, y, w, h, c, o, s) -- (x, y, width, height, color, outline width, radius)
    o = o or lineW
    s = s or o
    local l = s - (o / 2)
    lvg.setColor(c)
    if not DEBUG then
        lvg.rectangle("fill", x, y, w, h, s, s)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(o)
    lvg.rectangle("line", x + (o / 2), y + (o / 2), w - o, h - o, l, l)
end
local drawRect = drawRectangle

-- Accessories
local function drawCannon(x, y, r, w, c) -- (x, y, radius, width, color)
    lvg.push()
    lvg.translate(x, y)
    -- Default dimensions
    r = (r + 185) * size
    w = (w + 95) * size

    lvg.setColor(c)
    if not DEBUG then
        lvg.rectangle("fill", 0, -(w / 2), r, w, shapeR, shapeR)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.rectangle("line", lineW / 2, -(w / 2) + (lineW / 2), r - lineW, w - lineW, lineR, lineR)
    lvg.pop()
end

local function drawSprayer(x, y, r, w, c) -- (x, y, radius, width, color)
    lvg.push()
    lvg.translate(x, y)
    -- Default dimensions
    r = (r + 185) * size
    w = (w + 95) * size

    lvg.setColor(c)
    if not DEBUG then
        lvg.polygon("fill", 0, -lineW * 2, 0, lineW * 2, r, (w / 2), r, -(w / 2))
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.polygon("line", (lineW / 2), -lineW * 1.5, (lineW / 2), lineW * 1.5, r - (lineW / 2), (w / 2) - (lineW / 2),
        r - (lineW / 2), -(w / 2) + (lineW / 2))
    lvg.pop()
end

local function drawLauncher(x, y, r, w, c, i) -- (x, y, radius, width, color, triangle incline)
    lvg.push()
    lvg.translate(x, y)
    -- Default triangle dimensions
    r = (r + 155) * size
    w = (w + 165) * size
    -- Draw triangle
    lvg.setColor(c)
    if not DEBUG then
        lvg.polygon("fill", (15 * i * size), 0, r, (w / 2), r, -(w / 2))
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.polygon("line", (15 * i * size) + (lineW / 2), 0, r - (lineW / 2), (w / 2) - lineW,
        r - (lineW / 2), -(w / 2) + lineW)
    -- Default rectangle dimensions relative to triangle dimensions
    local rr = 125 * size
    local rw = w - (70 * size)
    -- Draw rectangle
    lvg.setColor(c)
    if not DEBUG then
        lvg.rectangle("fill", 0, -(rw / 2), rr, rw, shapeR, shapeR)
        lvg.setColor(color.line)
    end
    lvg.setLineWidth(lineW)
    lvg.rectangle("line", lineW / 2, -(rw / 2) + (lineW / 2), rr - lineW, rw - lineW, lineR,
        lineR)
    lvg.pop()
end

-- Groups
local function drawCannons(t, x, y, r, n, m, s, c, o, k, w) -- ("type", x, y, radius, total number of cannons, number of cannons side-by-side at each angle, space between side-by-side cannons, color, angular offset, { angular skip values }, width)
    w = w or 0
    k = k or {}
    -- Loop through skip values and deincrement so cannon 1 is the one facing the mouse
    for h, v in ipairs(k) do
        v = v == 1 and n + 1 or v
        k[h] = v - 1
    end
    s = t == "gunner" and s - 40 or s
    s = ((r * 2) + (s * 2)) * size
    for i = 1, n do
        if (not hasValue(k, i)) or k == { -1 } then -- I'M CONFUSED. WHY IS "k == { -1 }" HERE?
            local a = ((i / n) * 360) + (o or 0)    -- Calculate angles based on amount of cannons and add angular offset
            lvg.push()
            lvg.rotate(degToRad(a))
            if t == "flank" then
                lvg.rotate(degToRad(180))
            end
            for j = m, 1, -1 do
                y = centered(j, m, s)
                if t == "cannon" then
                    drawCannon(0, y, 0 + x, 0 + w, c)
                elseif t == "flank" or t == "small" then
                    drawCannon(0, y, -25 + x, 0 + w, c)
                elseif t == "sniper" then
                    drawCannon(0, y, 45 + x, 0 + w, c)
                elseif t == "destroyer" then
                    drawCannon(0, y, 0 + x, 30 + w, c)
                elseif t == "deployer" then
                    drawCannon(0 + (25 * size), y, 0 + x, 0 + w, c)
                    drawCannon(0, y, 0 + x, 30 + w, c)
                elseif t == "machineGun" then
                    drawSprayer(0, y, 0 + x, 60 + w, c)
                elseif t == "gunner" then
                    drawCannon(0, y, -15 + x, -45 + w, c)
                end
            end
            lvg.pop()
        end
    end
end

local function drawLaunchers(t, x, y, r, n, m, s, c, o, k, w) -- ("type", x, y, radius, total number of launchers, number of launchers side-by-side at each angle, space between side-by-side launchers, color, angular offset, { angular skip values }, width)
    w = w or 0
    k = k or {}
    -- Loop through skip values and deincrement so launcher 1 is the one facing the mouse
    for h, v in ipairs(k) do
        v = v == 1 and n + 1 or v
        k[h] = v - 1
    end
    s = ((r * 2) + (s * 2)) * size
    for i = 1, n do
        if (not hasValue(k, i)) or k == { -1 } then -- I'M CONFUSED. WHY IS "k == { -1 }" HERE?
            local a = ((i / n) * 360) + (o or 0)    -- Calculate angles based on amount of cannons and add angular offset
            lvg.push()
            lvg.rotate(degToRad(a))
            if t == "flank" then
                lvg.rotate(degToRad(180))
            end
            for j = m, 1, -1 do
                y = centered(j, m, s)
                if t == "launcher" then
                    drawLauncher(0, y, 15 + x, 0 + w, c, 3)
                elseif t == "flank" or t == "small" then
                    drawLauncher(0, y, 0 + x, -30 + w, c, 5.5)
                elseif t == "mega" or t == "medium" then
                    drawLauncher(0, y, 30 + x, 30 + w, c, 0)
                end
            end
            lvg.pop()
        end
    end
end

-- Player Body and Mount
local function drawMount(t, x, y, r, c, m, a) -- ("type", x, y, radius, color, mount rotation, { { "accessory", "type", x, y, total number of accessories, number of accessories side-by-side at each angle, space between side-by-side accessories, color, angular offset, { angular skip values }, width } })
    lvg.push()
    lvg.translate(x * scale, y * scale)
    a = a or { {} }
    r = r * 0.55 -- Reduce size
    -- Loop through table of accessories and create them
    for _, v in ipairs(a) do
        if v[1] == "cannon" then
            local w = -35
            local s = v[7] - 5
            if v[2] == "gunner" then
                s = s + 30
                w = -15
            end
            drawCannons(v[2], -75 + v[3], v[4], r, v[5], v[6], s, v[8], v[9], v[10], w)
        end
    end
    -- Draw mount body
    m = m or 0
    lvg.rotate(degToRad(m))
    if t == "circle" then
        drawCircle(0, 0, r * size, c)
    elseif t == "square" then
        drawSquare(0, 0, r * size, c)
    end
    lvg.pop()
end

local function drawBody(t, x, y, r, c) -- ("type", x, y, radius, color)
    lvg.push()
    if t == "circle" then
        drawCircle(x, y, r * size, c)
    elseif t == "square" or t == "squareAlt" then
        if t == "squareAlt" then
            lvg.rotate(degToRad(45))
        end
        drawSquare(x, y, r * size, c)
    elseif t == "pentagon" or t == "pentagonAlt" then
        if t == "pentagonAlt" then
            lvg.rotate(degToRad(180))
        end
        drawPentagon(x, y, (r + 25) * size, c)
    end
    lvg.pop()
end

-- Text
local function drawText(t, f, x, y, w) -- ("text", font, x, y, width)
    w = w or 500
    lvg.push()
    lvg.translate(-w / 2, 0)
    lvg.setColor(color.black)
    if not DEBUG then
        lvg.printf(t, f, x, y - 2, w, "center")     -- Top
        lvg.printf(t, f, x + 2, y - 2, w, "center") -- Top right
        lvg.printf(t, f, x + 2, y, w, "center")     -- Right
        lvg.printf(t, f, x + 2, y + 2, w, "center") -- Bottom right
        lvg.printf(t, f, x, y + 2, w, "center")     -- Bottom
        lvg.printf(t, f, x - 2, y + 2, w, "center") -- Bottom left
        lvg.printf(t, f, x - 2, y, w, "center")     -- Left
        lvg.printf(t, f, x - 2, y - 2, w, "center") -- Top left
        lvg.setColor(color.white)
    end
    lvg.printf(t, f, x, y, w, "center")
    lvg.pop()
end

-- Button
local buttons = {}
local Button = class("Button", {
    text = "",
    font = uiFontL,
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    color = color.darkGray,
    xOffset = 0,
    yOffset = 0,
    hovered = false,
    pressed = false
})

function Button:init(t, c, x, y, f)
    self.text = t or self.text
    self.font = f or self.font
    self.x = x or self.x
    self.y = y or self.y
    self.width = self.font:getWidth(self.text) + (uiW * 2) + 32
    self.height = self.font:getHeight(self.text) + (uiW * 2) + 16
    self.color = c or self.color
    self.xOffset = 0 or self.xOffset
    self.yOffset = 0 or self.yOffset

    table.insert(buttons, self)
end

function Button:isInside(x, y)
    if x > ((self.x + self.xOffset) - (self.width / 2)) and x < (self.x + self.xOffset) + (self.width / 2) and y > (self.y + self.yOffset) - (self.height / 2) and y < (self.y + self.yOffset) + (self.height / 2) then
        return true
    end
    return false
end

function Button:draw(x, y, ox, oy)
    self.x = x
    self.y = y
    self.xOffset = ox
    self.yOffset = oy
    lvg.push()
    lvg.translate(-self.width / 2, -self.height / 2)
    drawRect(self.x, self.y, self.width, self.height, self.color, uiW, uiR)
    if self.hovered then
        lvg.setColor(color.hover)
        lvg.rectangle("fill", self.x, self.y, self.width, self.height, uiR, uiR)
    end
    lvg.pop()
    drawText(self.text, self.font, self.x, (self.y + uiW + 8) - self.height / 2, self.width)
    lvg.push()
    lvg.translate(-self.width / 2, -self.height / 2)
    lvg.setColor(self.pressed and color.shadow or color.highlight)
    lvg.rectangle("fill", self.x + uiW, self.y + uiW, self.width - (uiW * 2), (self.height - (uiW * 2)) / 2, uiR - uiW,
        uiR - uiW)
    lvg.pop()
end

-- USER INTERFACE
-- Initialize
local typeBtn, posBtn, numBtn, parallelBtn, spaceBtn, colorBtn, offsetBtn, addBtn
local function initUI()
    typeBtn = Button("Normal Cannon", color.cyan)
    function typeBtn:click()
        print("1 CLICKED")
    end

    posBtn = Button("(0, 0)", color.green)
    function posBtn:click()
        print("2 CLICKED")
    end

    numBtn = Button("1", color.red)
    function numBtn:click()
        print("3 CLICKED")
    end

    parallelBtn = Button("1", color.yellow)
    function parallelBtn:click()
        print("4 CLICKED")
    end

    spaceBtn = Button("0", color.indigo)
    function spaceBtn:click()
        print("5 CLICKED")
    end

    colorBtn = Button("Gray", color.purple)
    function colorBtn:click()
        print("6 CLICKED")
    end

    offsetBtn = Button("0", color.orange)
    function offsetBtn:click()
        print("7 CLICKED")
    end

    addBtn = Button("+")
    function addBtn:click()
        print("8 CLICKED")
    end
end

-- Draw
local uiTotalW = windowW - 32
local uiTopColumns = 8
local uiTopX = windowW / 2
local uiTopY = 64
local uiLabelO = -50
local function drawUI()
    lvg.push()
    if DEBUG then
        lvg.setColor(color.line)
        lvg.setLineWidth(16 * 2)
        lvg.rectangle("line", 0, 0, windowW, windowH)
    end
    lvg.translate(uiTopX, uiTopY)
    for i, b in ipairs(buttons) do
        b:draw(centered(i, uiTopColumns, uiTotalW), 0, uiTopX, uiTopY)
    end
    drawText("Type", uiFont, centered(1, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Position", uiFont, centered(2, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Amount", uiFont, centered(3, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Amount Parallel", uiFont, centered(4, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Parallel Spacing", uiFont, centered(5, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Color", uiFont, centered(6, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    drawText("Offset", uiFont, centered(7, uiTopColumns, uiTotalW), uiLabelO, uiTotalW / uiTopColumns)
    lvg.pop()
end

-- MAIN
function love.load()
    lvg.setBackgroundColor(color.gray)
    initUI()
end

function love.mousemoved(x, y)
    local overBtn = false
    for _, b in ipairs(buttons) do
        if b:isInside(x, y) then
            overBtn = true
            if not b.pressed then
                b.hovered = true
            end
        end
        if not b:isInside(x, y) then
            b.hovered = false
        end
    end
    lvm.setCursor(lvm.getSystemCursor(overBtn == true and "hand" or "arrow"))
end

function love.mousepressed(x, y)
    for _, b in ipairs(buttons) do
        if b:isInside(x, y) then
            b.pressed = true
            b.hovered = false
        end
    end
end

function love.mousereleased(x, y)
    for _, b in ipairs(buttons) do
        if b:isInside(x, y) then
            b:click()
            b.hovered = true
        end
        b.pressed = false
    end
end

function love.resize()
    windowW, windowH = lvg.getDimensions()
    uiTotalW = windowW - 32
    uiTopX = windowW / 2
end

function love.update(dt)

end

local cRotation = 0
function love.draw()
    -- BOUNDING BOX
    lvg.push()
    lvg.translate(windowW / 2, windowH / 2)
    lvg.setColor(color.lightGray)
    lvg.rectangle("fill", -800, -500, 1600, 1000)
    lvg.pop()

    -- POLYGONS
    lvg.push()
    lvg.translate((windowW / 2) + 100, (windowH / 2) + 250)
    lvg.rotate(degToRad(-cRotation))
    drawCircle(50 * scale, 0, 30 * scale, color.white)
    lvg.pop()
    lvg.push()
    lvg.translate((windowW / 2) - 100, (windowH / 2) + 250)
    lvg.rotate(degToRad(cRotation / 2))
    drawSquare(0, 50 * scale, 60 * scale, color.yellow)
    lvg.pop()
    lvg.push()
    lvg.translate((windowW / 2) + 100, (windowH / 2) - 250)
    lvg.rotate(degToRad(cRotation))
    drawPentagon(0, 50 * scale, 90 * scale, color.indigo)
    lvg.pop()
    lvg.push()
    lvg.translate((windowW / 2) + 200, (windowH / 2) - 375)
    lvg.rotate(degToRad(-cRotation / 2))
    drawPentagon(50 * scale, 0, 90 * scale, color.green)
    lvg.pop()
    cRotation = cRotation + 0.75

    local mX, mY = lvm.getPosition()
    -- TANK 1
    lvg.push()
    lvg.translate((windowW / 2) - 300, windowH / 2)
    local mTX, mTY = lvg.inverseTransformPoint(mX, mY)
    lvg.rotate(math.atan2(mTY, mTX))

    -- Accessory(s)
    -- All
    drawLaunchers("mega", 0, 0, radius, 1, 1, 0, color.darkGray, 320)
    drawLaunchers("launcher", 0, 0, radius, 1, 1, 0, color.darkGray, 280)
    drawCannons("gunner", 0, 0, radius, 1, 2, 0, color.darkGray, 240)
    drawCannons("machineGun", 0, 0, radius, 1, 1, 0, color.darkGray, 200)
    drawCannons("deployer", 0, 0, radius, 1, 1, 0, color.darkGray, 120)
    drawCannons("destroyer", 0, 0, radius, 1, 1, 0, color.darkGray, 80)
    drawCannons("sniper", 0, 0, radius, 1, 1, 0, color.darkGray, 40)
    drawCannons("flank", 0, 0, radius, 1, 1, 0, color.darkGray, -20)
    drawCannons("cannon", 0, 0, radius, 1, 1, 0, color.darkGray)

    -- Machine Gunner
    -- drawCannons("machineGun", -75, 0, radius, 1, 1, 0, color.darkGray, 0, {}, 120)
    -- drawCannons("machineGun", -45, 0, radius, 1, 1, 0, color.darkGray, 0, {}, 60)
    -- drawCannons("machineGun", -15, 0, radius, 1, 1, 0, color.darkGray)

    -- Body
    drawBody("circle", 0, 0, radius, color.cyan)
    drawMount("circle", 0, 0, radius, color.darkGray, 0, { { "cannon", "cannon", 0, 0, 1, 1, 0, color.darkGray } })
    lvg.pop()

    -- TANK 2
    lvg.push()
    lvg.translate((windowW / 2) + 300, windowH / 2)
    mTX, mTY = lvg.inverseTransformPoint(mX, mY)
    lvg.rotate(math.atan2(mTY, mTX))

    -- Penta-Shot
    drawCannons("small", -25, 0, radius, 16, 1, 0, color.darkGray, 0,
        { 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16 })
    drawCannons("small", 0, 0, radius, 16, 1, 0, color.darkGray, 0,
        { 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })
    drawCannons("cannon", 0, 0, radius, 1, 1, 0, color.darkGray)

    -- Body
    drawBody("pentagon", 0, 0, radius, color.purple)
    drawMount("square", 0, 0, radius, color.darkGray, 45,
        { { "cannon", "cannon", 0, 0, 1, 2, 0, color.darkGray } })
    lvg.pop()

    drawUI()
end
