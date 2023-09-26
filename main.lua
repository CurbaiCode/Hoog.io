--[[
 -- main.lua
 -- DPEio Builder 0.2
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local UI = require("UI")
local lvg = love.graphics
local lvm = love.mouse
local lvk = love.keyboard

-- CONSTANTS
local DEBUG = false
UI.DEBUG = DEBUG and true or false
local windowW, windowH = lvg.getDimensions()
local outlineWidth = 4
local shapeRadius = 4
local fadeStart = 0.15

-- Settings
local showNames = true

-- FUNCTIONS
-- Convert between radians and degrees
local function degToRad(d)
    return d * math.pi / 180
end

local function radToDeg(r)
    return r * 180 / math.pi
end

-- Distribute points between a range that is centered on 0: e.g. if range is 200, values are between 100 and -100
local function centered(i, n, t) -- (item number, number of items, total space or range)
    return i * (t / n) - ((t / n) * ((n + 1) / 2))
end

-- Rotate point by angle around (0, 0)
local function rotateBy(x, y, a) -- (x, y, angle)
    return ((x * math.cos(a)) - (y * math.sin(a))), ((x * math.sin(a)) + (y * math.cos(a)))
end

-- Generate UUID as string
local currentID = 0
local function newID()
    currentID = currentID + 1
    return tostring(currentID)
end

-- Clamp value between two values
local function clamp(v, m, n) -- (value, min, max)
    return math.min(math.max(v, m), n)
end

-- Deep copy a table
local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res --setmetatable(res, getmetatable(obj))
end

-- Check if table contains value
local function hasValue(t, s) -- (table, search)
    for _, v in ipairs(t) do
        if v == s then
            return true
        end
    end
    return false
end

-- Combine tables
-- local function combineTables(t1, t2) -- (table1, table2)
--     for i = 1, #t2 do
--         t1[#t1 + 1] = t2[i]
--     end
--     return t1
-- end

-- Compute recoil
local function getRecoil(r, rt)
    return math.sin(clamp((r - rt) / math.min(0.2, r), 0, 1) * math.pi) * 4
end

-- Compute fade
local function getFade(h)
    return h <= fadeStart and (h / fadeStart) or 1
end

-- Fire accessory
local function fire(o, p, px, py, pa, s)
    local angleT = pa + degToRad(s.angle)
    local x, y = rotateBy(s.x + s.length, s.y, angleT)
    local randAngle = angleT + ((math.random() - 0.5) * degToRad(s.stats.spread))
    local randSpeed = s.stats.speed + ((math.random() - 0.5) * 2)
    local newO = o(p, px, py, x, y, math.cos(randAngle) * randSpeed, math.sin(randAngle) * randSpeed, s.size, {
        health = s.stats.health,
        penetration = s.stats.penetration,
        damage = s.stats.damage
    }, p.color, s.shape)
    p.objects[newO.id] = newO
    s.reloadTime = s.stats.reload
end

-- Draw body
local function drawBody(c, s)
    lvg.translate(s.x, s.y)
    local tTX, tTY = lvg.inverseTransformPoint((s.targetX or s.owner.targetX), (s.targetY or s.owner.targetY))
    s.angle = math.atan2(tTY, tTX)
    lvg.rotate(s.angle)
    for _, a in ipairs(s.accessories) do
        a:draw()
    end
    if s.shape == "circle" then
        UI.circle(0, 0, s.radius, c, outlineWidth)
    elseif s.shape == "square" or s.shape == "squareAlt" then
        if s.shape == "squareAlt" then
            lvg.push()
            lvg.rotate(degToRad(45))
        end
        UI.rect(0, 0, s.radius * 2, s.radius * 2, c, outlineWidth, shapeRadius, "both")
        if s.shape == "squareAlt" then
            lvg.pop()
        end
    elseif s.shape == "triangle" or s.shape == "triangleAlt" then
        if s.shape == "triangleAlt" then
            lvg.push()
            lvg.rotate(degToRad(180))
        end
        UI.ngon("normal", 0, 0, 3, s.radius, c, outlineWidth)
        if s.shape == "triangleAlt" then
            lvg.pop()
        end
    elseif s.shape == "pentagon" or s.shape == "pentagonAlt" then
        if s.shape == "pentagonAlt" then
            lvg.push()
            lvg.rotate(degToRad(180))
        end
        UI.ngon("normal", 0, 0, 5, s.radius, c, outlineWidth)
        if s.shape == "pentagonAlt" then
            lvg.pop()
        end
    elseif s.shape == "hexagon" or s.shape == "hexagonAlt" then
        if s.shape == "hexagon" then
            lvg.push()
            lvg.rotate(degToRad(30))
        end
        UI.ngon("normal", 0, 0, 6, s.radius, c, outlineWidth)
        if s.shape == "hexagon" then
            lvg.pop()
        end
    elseif s.shape == "octagon" or s.shape == "octagonAlt" then
        if s.shape == "octagon" then
            lvg.push()
            lvg.rotate(degToRad(22.5))
        end
        UI.ngon("normal", 0, 0, 8, s.radius, c, outlineWidth)
        if s.shape == "octagon" then
            lvg.pop()
        end
    end
end

-- CLASSES

-- OBJECTS
-- Bullet
local Bullet = class("Bullet")
function Bullet:init(owner, originX, originY, x, y, vx, vy, radius, statsOffset, color)
    self.owner = owner
    self.id = newID()
    self.originX = originX or 0
    self.originY = originY or 0
    self.x = x or 0
    self.y = y or 0
    self.vx = vx or 0
    self.vy = vy or 0
    self.radius = radius / 2
    self.statsOffset = statsOffset or {
        health = 0,
        penetration = 0,
        damage = 0
    }
    self.color = color or UI.color.cyan
    self.health = 2.7 + self.statsOffset.health
end

function Bullet:draw()
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    self.vx = self.vx * 0.99
    self.vy = self.vy * 0.99
    lvg.push()
    lvg.translate(self.originX, self.originY)
    local fade = getFade(self.health)
    UI.circle(self.x, self.y, self.radius + (4 * (1 - fade)), self.color, outlineWidth, fade)
    lvg.pop()
end

function Bullet:delete()
    self.owner.objects[self.id] = nil
end

-- Trap
local Trap = class("Trap")
function Trap:init(owner, originX, originY, x, y, vx, vy, radius, statsOffset, color, shape)
    self.owner = owner
    self.id = newID()
    self.originX = originX or 0
    self.originY = originY or 0
    self.x = x or 0
    self.y = y or 0
    self.vx = vx or 0
    self.vy = vy or 0
    self.rotation = 0
    self.radius = radius / 2
    self.statsOffset = statsOffset or {
        health = 0,
        penetration = 0,
        damage = 0
    }
    self.color = color or UI.color.cyan
    self.health = 10 + self.statsOffset.health
    self.shape = shape
end

function Trap:draw()
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    self.rotation = self.rotation + ((self.vx + self.vy) / 2)
    self.vx = self.vx * 0.95 -- Good
    self.vy = self.vy * 0.95
    lvg.push()
    lvg.translate(self.originX + self.x, self.originY + self.y)
    local fade = getFade(self.health)
    lvg.push()
    lvg.rotate(degToRad(self.rotation))
    if self.shape == "square" then
        UI.stargon("small", 0, 0, 4, self.radius + (4 * (1 - fade)), self.color, outlineWidth, fade)
    else
        UI.stargon("small", 0, 0, 3, self.radius + (4 * (1 - fade)), self.color, outlineWidth, fade)
    end
    lvg.pop()
    lvg.pop()
end

Trap.delete = Bullet.delete

-- ACCESSORIES
-- Cannon
local Cannon = class("Cannon")
function Cannon:init(owner, type, subtype, x, y, angle, lengthOffset, widthOffset, stats, recoil, size)
    self.owner = owner
    self.type = type or "normal"
    self.subtype = subtype or "normal"
    self.scale = self.owner.scale
    self.x = (x * self.scale) or 0
    self.y = (y * self.scale) or 0
    self.angle = angle or 0
    self.lengthOffset = lengthOffset or 0
    self.length = self.owner.radius + ((24 * self.scale) + self.lengthOffset)
    self.widthOffset = widthOffset or 0
    self.width = self.owner.radius + ((-2 * self.scale) + self.widthOffset)
    self.recoil = recoil
    self.stats = stats
    self.reloadTime = 0
    self.color = UI.color.darkGray
    self.size = self.width + ((size or 0) * self.scale)
    if self.type == "machineGun" then
        self.size = self.owner.radius + ((-1) * self.scale)
    end
    -- if self.subtype ~= "normal" then
    --     if self.subtype == "heatseeker" then
    --         self.color = UI.color.red
    --     end
    -- end
end

function Cannon:draw()
    lvg.push()
    lvg.rotate(degToRad(self.angle))
    local recoil = getRecoil(self.stats.reload, self.reloadTime)
    if self.type == "machineGun" then
        UI.trapeziod(self.x, self.y, self.length - recoil, 12, self.width, self.color, outlineWidth)
    else
        UI.rect(self.x, self.y, self.length - recoil, self.width, self.color, outlineWidth, shapeRadius, "vertical")
    end
    lvg.pop()
end

function Cannon:fire(p, px, py, pa)
    fire(Bullet, p, px, py, pa, self)
end

-- Launcher
local Launcher = class("Launcher")
function Launcher:init(owner, type, subtype, x, y, angle, lengthOffset, widthOffset, stats, recoil, size, shape)
    self.owner = owner
    self.type = type or "normal"
    self.subtype = subtype or "normal"
    self.scale = self.owner.scale
    self.x = (x * self.scale) or 0
    self.y = (y * self.scale) or 0
    self.angle = angle or 0
    self.lengthOffset = lengthOffset or 0
    self.length = self.owner.radius + ((20 * self.scale) + self.lengthOffset)
    self.widthOffset = widthOffset or 0
    self.width = self.owner.radius + ((-2 * self.scale) + self.widthOffset)
    self.recoil = recoil
    self.stats = stats
    self.reloadTime = 0
    self.color = UI.color.darkGray
    self.size = self.width + ((size or 0) * self.scale)
    self.shape = shape
end

function Launcher:draw()
    lvg.push()
    lvg.rotate(degToRad(self.angle))
    local recoil = getRecoil(self.stats.reload, self.reloadTime)
    local offset = (8 + (self.lengthOffset / 2)) * self.scale
    local w = 16
    if self.type == "builder" then
        offset = offset + (8 * self.scale)
        w = 8
    end
    UI.trapeziod(self.x + self.owner.radius + offset - outlineWidth - recoil, self.y,
        self.length - self.owner.radius - (offset / 2), self.width / 2, self.width + w, self.color, outlineWidth)
    UI.rect(self.x, self.y, self.owner.radius + offset - recoil, self.width, self.color, outlineWidth, shapeRadius,
        "vertical")
    lvg.pop()
end

function Launcher:fire(p, px, py, pa)
    fire(Trap, p, px, py, pa, self)
end

-- MOUNT
local Mount = class("Mount")
function Mount:init(owner, shape, x, y, targetX, targetY)
    self.owner = owner
    self.shape = shape
    self.scale = self.owner.scale
    self.x = (x * self.scale) or 0
    self.y = (y * self.scale) or 0
    self.targetX = targetX or nil
    self.targetY = targetY or nil
    self.angle = 0
    self.radius = self.owner.radius * 0.52
    self.color = self.owner.color
    self.appearance = UI.color.darkGray
    self.stats = {
        speed = self.owner.stats.speed - 1,
        health = self.owner.stats.health,
        penetration = self.owner.stats.penetration * 2,
        damage = self.owner.stats.damage,
        reload = self.owner.stats.reload,
        spread = self.owner.stats.spread
    }
    self.accessories = {}
    self.objects = {}

    if DEBUG then
        self.appearance = self.color
    end
end

function Mount:draw()
    lvg.push()
    drawBody(self.appearance, self)
    lvg.pop()
end

-- PLAYER
local players = {}
local Player = class("Player")
function Player:init(name, level, color, shape, x, y)
    self.name = name or "An Unnamed Player"
    self.color = color or UI.color.cyan
    self.shape = shape or "circle"
    self.x = x or 0
    self.y = y or 0
    self.targetX = 0
    self.targetY = 0
    self.level = level or 1
    self.scale = 1 + ((self.level - 1) / 100)
    self.radius = 30 * self.scale
    self.stats = {
        healthRegen = 1,
        maxHealth = 1,
        bodyDamage = 1,
        speed = 8,
        health = 0,
        penetration = 1,
        damage = 1,
        reload = 0.6,
        spread = 15,
        movementSpeed = 1
    }
    self.autoFire = false
    self.autoSpin = false
    self.angle = 0
    self.mounts = {}
    self.accessories = {}
    self.objects = {}

    table.insert(players, self)
end

function Player:draw()
    lvg.push()
    drawBody(self.color, self)
    for _, m in ipairs(self.mounts) do
        m:draw()
    end
    lvg.pop()
end

function Player:drawLabel()
    lvg.push()
    lvg.translate(self.x, self.y - (self.radius * 2))
    UI.text(self.name)
    lvg.pop()
end

function Player:addAccessory(type, subtype, subsubtype, x, y, lengthOffset, widthOffset, amount, parallel, space,
                             angularOffset, skips, caller, reference)
    caller = caller or self
    reference = reference or self
    local Accessory = Cannon
    local stats = {
        speed = caller.stats.speed,
        health = caller.stats.health,
        penetration = caller.stats.penetration,
        damage = caller.stats.damage,
        reload = caller.stats.reload,
        spread = caller.stats.spread
    }
    local recoil = 2
    local size = 0
    lengthOffset = lengthOffset * 8
    widthOffset = widthOffset * 2
    space = ((reference.radius * 2) + (space * 2 * reference.scale)) / reference.scale
    for i, v in ipairs(skips) do
        skips[i] = v == 0 and amount or v
    end

    local tmpStats = copy(stats)
    local tmpLengthOffset = lengthOffset
    local tmpWidthOffset = widthOffset
    local tmpSpace = space
    local tmpRecoil = recoil
    local tmpSize = size

    local shape = "triangle"
    for i = 1, amount do
        if not hasValue(skips, i) then
            local a = ((i / amount) * 360) + (angularOffset or 0)
            for j = parallel, 1, -1 do
                if type == "cannon" then
                    if subtype ~= "normal" then
                        if subtype == "sniper" then
                            tmpLengthOffset = lengthOffset + 8 -- Exact
                            tmpStats.reload = stats.reload + 0.6
                            tmpStats.speed = stats.speed + 4
                            tmpStats.damage = stats.damage + 5
                            tmpStats.spread = stats.spread - 5
                        elseif subtype == "destroyer" then
                            tmpWidthOffset = widthOffset + 16            -- Exact
                            tmpSpace = space + 32                        -- Exact
                            tmpStats.penetration = stats.penetration * 2 -- Exact
                            tmpStats.damage = stats.damage * 30 / 7      -- Exact
                            tmpStats.reload = stats.reload * 8           -- Exact
                            tmpStats.speed = stats.speed / 1.5           -- Exact
                            tmpRecoil = recoil * 15                      -- Exact
                        elseif subtype == "machineGun" then
                            tmpWidthOffset = widthOffset + 16            -- Exact
                            tmpStats.spread = stats.spread + 15
                            tmpStats.reload = stats.reload / 2           -- Exact
                        elseif subtype == "gunner" then
                            tmpLengthOffset = lengthOffset - 4           -- Exact
                            tmpWidthOffset = widthOffset - 8             -- Exact
                            tmpSpace = space - 20                        -- Exact
                            tmpStats.damage = stats.damage - 5
                            tmpStats.penetration = stats.penetration - 5
                            tmpStats.speed = stats.speed + 5
                            tmpStats.reload = stats.reload + 0.3
                            tmpStats.spread = stats.spread - 10
                            tmpRecoil = recoil / 2
                        end
                    end
                elseif type == "launcher" then
                    Accessory = Launcher
                    tmpStats.penetration = stats.penetration * 2
                    -- Inherited from Sniper
                    tmpStats.reload = stats.reload + 0.6
                    tmpStats.speed = stats.speed + 4
                    tmpStats.damage = stats.damage + 5
                    tmpStats.spread = stats.spread - 5
                    if subtype ~= "normal" then
                        if subtype == "mega" or subtype == "medium" then
                            tmpLengthOffset = lengthOffset + 8      -- Exact
                            tmpWidthOffset = widthOffset + 16       -- Exact
                            if subtype == "mega" then
                                tmpSize = size + 8                  -- Exact
                                tmpStats.health = stats.health + 14 -- Exact
                                tmpStats.penetration = stats.penetration + 2
                                tmpStats.damage = stats.damage + 2
                                tmpStats.speed = stats.speed - 2
                            elseif subtype == "medium" then
                                tmpSize = size - 4                 -- Exact
                                tmpStats.health = stats.health + 7 -- Exact
                                tmpStats.penetration = stats.penetration + 1
                                tmpStats.damage = stats.damage + 1
                                tmpStats.speed = stats.speed - 0.2
                            end
                        elseif subtype == "small" then
                            tmpWidthOffset = widthOffset - 8   -- Exact
                            tmpStats.health = stats.health - 5 -- Exact
                            tmpStats.penetration = stats.penetration - 1
                            tmpStats.damage = stats.damage - 1
                            tmpStats.speed = stats.speed + 8
                        elseif subtype == "builder" then
                            shape = "square"
                            tmpStats.health = stats.health * 1.5
                            tmpStats.penetration = stats.penetration + 1
                            tmpStats.damage = stats.damage + 1
                        end
                    end
                end
                y = centered(j, parallel, tmpSpace)
                table.insert(caller.accessories,
                    Accessory(caller, subtype, subsubtype, x, y, a, tmpLengthOffset, tmpWidthOffset, tmpStats,
                        tmpRecoil, tmpSize, shape))
            end
        end
    end
end

Mount.addAccessory = Player.addAccessory
function Player:addMount(shape, x, y, accessories)
    accessories = accessories or {}
    local mount = Mount(self, shape, x, y)
    for _, a in ipairs(accessories) do
        local w = 2
        local l = -1
        local g = -15
        if a[1] == "cannon" then
            if a[2] == "gunner" then
                w = w + 1
                g = g + 8
            end
        end
        mount:addAccessory(a[1], a[2], a[3], a[4], a[5], a[6] + (l * self.scale), a[7] + w, a[8], a[9], a[10] + g, a[11],
            a[12], mount, mount.owner, 0)
    end

    table.insert(self.mounts, mount)
end

-- HUD
local HUD = class("HUD")
function HUD:init()
    local typeBtn = UI.Button("Normal Cannon", UI.color.cyan)
    function typeBtn:click()
        print("1 CLICKED")
    end

    local posBtn = UI.Button("(0, 0)", UI.color.green)
    function posBtn:click()
        print("2 CLICKED")
    end

    local numBtn = UI.Button("1", UI.color.red)
    function numBtn:click()
        print("3 CLICKED")
    end

    local parallelBtn = UI.Button("1", UI.color.yellow)
    function parallelBtn:click()
        print("4 CLICKED")
    end

    local spaceBtn = UI.Button("0", UI.color.indigo)
    function spaceBtn:click()
        print("5 CLICKED")
    end

    local colorBtn = UI.Button("Gray", UI.color.purple)
    function colorBtn:click()
        print("6 CLICKED")
    end

    local offsetBtn = UI.Button("0", UI.color.orange)
    function offsetBtn:click()
        print("7 CLICKED")
    end

    local addBtn = UI.Button("+")
    function addBtn:click()
        print("8 CLICKED")
    end
end

function HUD:draw()
    for i, b in ipairs(UI.buttons) do
        b:draw()
    end
end

-- UPDATE FUNCTIONS
local function drawObjects(p)
    for _, o in pairs(p) do
        o:draw()
    end
end

-- GARBAGE COLLECT FUNCTIONS
-- Objects
-- Garbage collect objects
local function gcObjects(dt, p)
    for _, o in pairs(p) do
        if o:instanceOf(Bullet) or o:instanceOf(Trap) then
            o.health = o.health - dt
            if o.health <= -fadeStart then
                o:delete()
            end
        end
    end
end

-- MAIN
function love.load()
    lvg.setBackgroundColor(UI.color.gray)

    HUD:init()

    local player1 = Player()
    player1.color = UI.color.gray
    player1.autoFire = true
    player1.autoSpin = true
    player1:addAccessory("launcher", "builder", "normal", 0, 0, 0, 0, 3, 1, 0, 0, {})
    player1:addAccessory("launcher", "normal", "normal", 0, 0, 0, 0, 3, 1, 0, 60, {})
    player1:addMount("circle", 0, 0, {
        { "cannon", "machineGun", "normal", 0, 0, -1, 8, 1, 1, 0, 0, {} },
        { "cannon", "machineGun", "normal", 0, 0, 0,  0, 1, 1, 0, 0, {} }
    })

    local player2 = Player("Administrator", 45, UI.color.indigo, "triangleAlt", 200, 200)
    player2:addAccessory("cannon", "normal", "normal", 0, 0, 1, 0, 1, 1, 0, 0, {})
    player2:addAccessory("cannon", "machineGun", "normal", 0, 0, -2, 24, 1, 1, 0, 0, {})
    player2:addAccessory("cannon", "machineGun", "normal", 0, 0, -1, 12, 1, 1, 0, 0, {})
    player2:addAccessory("cannon", "machineGun", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {})
    player2:addMount("square", 0, 16, {
        { "cannon", "gunner", "normal", 0, 0, 0, 0, 1, 2, 0, 0, {} }
    })
    player2:addMount("squareAlt", 0, -16, {
        { "cannon", "machineGun", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {} }
    })

    local player3 = Player("Jack Kelly", 30, UI.color.green, "circle", 200, -200)
    -- player3.autoFire = true
    player3.autoSpin = true
    player3:addAccessory("cannon", "normal", "normal", 0, 0, -1, 0, 1, 2, 0, 0, {})
    player3:addAccessory("cannon", "normal", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {})
    player3:addMount("circle", 0, 0, {
        { "cannon", "normal", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {} }
    })

    local player4 = Player("Les", 45, UI.color.red, "hexagon", -200, -200)
    player4:addAccessory("cannon", "normal", "normal", 0, 0, 0, 0, 6, 1, 0, 0, {})
    player4:addMount("pentagon", 0, 0)

    local player5 = Player("Developer", 60, UI.color.indigo, "pentagon", -200, 200)
    player5:addAccessory("cannon", "gunner", "normal", 0, 0, -2, 0, 1, 3, 8, 0, {})
    player5:addAccessory("cannon", "gunner", "normal", 0, 0, -1, 0, 1, 2, 0, 0, {})
    player5:addAccessory("cannon", "gunner", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {})
    player5:addMount("circle", 0, 0, {
        { "cannon", "normal", "normal", 0, 0, 0, 0, 1, 2, 0, 0, {} }
    })

    local player6 = Player("Spot", 15, UI.color.purple, "circle", 400, 0)
    player6.autoSpin = true
    player6:addAccessory("launcher", "builder", "normal", 0, 0, 0, 18, 1, 1, 0, 0, {})
    player6:addMount("square", 0, 0)

    local player7 = Player("Jerry Spinelli", 1, UI.color.cyan, "square", -400, 0)
    -- player7.autoFire = true
    player7:addAccessory("cannon", "normal", "normal", 0, 0, 1, 0, 1, 1, 0, 0, {})
    player7:addAccessory("cannon", "machineGun", "normal", 0, 0, 0, 0, 1, 1, 0, 0, {})
    player7:addMount("circle", 0, 0)

    local player8 = Player("Arena Closer", 150, UI.color.yellow, "circle", 0, 400)
    player8:addAccessory("cannon", "destroyer", "normal", 0, 0, -1, -8, 1, 1, 0, 0, {})
end

function love.mousemoved(x, y)
    UI.mousemoved(x, y)
end

function love.mousepressed(x, y)

end

function love.mousereleased(x, y)

end

function love.keypressed()

end

function love.resize()
    windowW, windowH = lvg.getDimensions()
end

local autoRotation = 0
function love.update(dt)
    for i, p in ipairs(players) do
        -- Check for AutoSpin
        if p.autoSpin then
            p.targetX, p.targetY = rotateBy(p.radius * 3, 0, autoRotation)
            p.targetX = p.targetX + (windowW / 2) + p.x
            p.targetY = p.targetY + (windowH / 2) + p.y
        else
            p.targetX, p.targetY = lvm.getPosition()
        end
        -- Fire player accessories
        for _, a in ipairs(p.accessories) do
            if a.reloadTime <= 0 and (((lvm.isDown(1) or lvk.isDown("space")) and not UI.mouseoverbutton) or p.autoFire) then
                a:fire(p, p.x, p.y, p.angle)
            end
            a.reloadTime = a.reloadTime - dt
        end
        -- Fire mount accessories
        for _, m in ipairs(p.mounts) do
            if i == 1 or i == 5 then
                m.targetX, m.targetY = rotateBy(150, 0, -autoRotation)
                m.targetX = m.targetX + (windowW / 2)
                m.targetY = m.targetY + (windowH / 2)
            end
            for _, a in ipairs(m.accessories) do
                if a.reloadTime <= 0 and (m.targetX ~= nil and m.targetY ~= nil) then
                    local targetOffsetX, targetOffsetY = rotateBy(m.x, m.y, p.angle)
                    a:fire(m, p.x + targetOffsetX, p.y + targetOffsetY, p.angle + m.angle)
                end
                a.reloadTime = a.reloadTime - dt
            end
        end
        -- Garbage collect player dead objects
        gcObjects(dt, p.objects)
        -- Garbage collect mount dead objects
        for _, m in ipairs(p.mounts) do
            gcObjects(dt, m.objects)
        end
    end
    autoRotation = autoRotation + 0.01
end

function love.draw()
    -- GAME AREA
    lvg.push()
    lvg.translate(windowW / 2, windowH / 2)
    lvg.setColor(UI.color.lightGray)
    lvg.rectangle("fill", -400, -400, 800, 800)
    lvg.pop()

    -- PLAYERS
    lvg.push()
    lvg.translate(windowW / 2, windowH / 2)
    for _, p in ipairs(players) do
        -- Draw player objects
        drawObjects(p.objects)
        -- Draw mount objects
        for _, m in ipairs(p.mounts) do
            drawObjects(m.objects)
            if DEBUG then
                UI.circle(m.targetX - (windowW / 2), m.targetY - (windowH / 2), 10, UI.color.brown, outlineWidth)
            end
        end
    end
    -- Draw players
    for _, p in ipairs(players) do
        p:draw()
        if DEBUG then
            lvg.push()
            lvg.translate(-windowW / 2, -windowH / 2)
            UI.circle(p.targetX, p.targetY, 15, p.color, outlineWidth)
            lvg.pop()
        end
    end
    if showNames then
        for _, p in ipairs(players) do
            p:drawLabel()
        end
    end
    lvg.pop()

    -- Draw HUD
    HUD:draw()
end
