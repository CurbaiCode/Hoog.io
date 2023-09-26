--[[
 --	player.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local utils = require("utils")
local UI = require("UI")

-- SHORTCUTS
local lvg = love.graphics
local lvk = love.keyboard

-- SETTINGS
ShowNames = true
local maxLevel = 60

-- MAIN
local P = class("Player")
function P:init(x, y, color, name, shape, score, input)
    self.vx, self.vy = 0, 0
    self.tx, self.ty = 0, 0
    self.score = score or 0
    self.level = 1
    self.color = color or UI.color.cyan
    self.name = name or ""
    self.radius = 30
    self.stats = {
        healthRegen = 1, -- Unused
        maxHealth = 50,
        bodyDamage = 1,  -- Unused
        -- Object Stats
        speed = 8,
        health = 2.7,
        penetration = 1, -- Unused
        damage = 1,
        reload = 0.6,
        -- Hidden Object Stats
        spread = 15,

        movementSpeed = 10
    }
    self.health = utils.copy(self.stats.maxHealth)
    self.autoFire = false
    self.autoSpin = false
    self.input = input or {
        up = "w",
        down = "s",
        left = "a",
        right = "d",
        fire = "space",
        autoFire = "e",
        autoSpin = "c"
    }
    self.inputStrength = {
        up = 0,
        down = 0,
        left = 0,
        right = 0,
        fire = 0
    }
    self.accessories = {}
    self.objects = {}
    self.mounts = {} -- Unused
    self.img = GVG.Group(nil, x, y)

    local body = GVG.Shape(shape)
    body.color = self.color
    body.uniforms.radius[1] = self.radius
    body.offset = OFFSET
    body:createMesh()
    body:compileShader()
    self.img:add(body)

    self.extra = GVG.Group()
    self.healthBar = UI.Bar(0, -46, 4, self.stats.maxHealth, self.health, UI.color.green)
    self.extra:add(self.healthBar.img)
    self.labelLevel = GVG.Text("Lvl 0", nil, 12, "bitmapsdf", 0, 46)
    self.extra:add(self.labelLevel)
    if ShowNames then
        local labelName = GVG.Text(self.name, nil, 12, "bitmapsdf", 0, 62)
        self.extra:add(labelName)
    end
    self.img:add(self.extra)
end

function P:add(type, item)
    if type == "accessory" then
        table.insert(self.accessories, item)
        self.img:add(item.img, 1)
    elseif type == "mount" then
        table.insert(self.mounts, item)
        self.img:add(item.img)
    end
end

function P:update(dt, ar, mx, my)
    self.level = math.floor((math.sqrt(math.pi) * math.pow(self.score, 1 / math.pi)) + 1)
    self.labelLevel.text = "Lvl " .. self.level
    if self.level < 15 then
        self.labelLevel.color = UI.color.white
    elseif self.level < 30 then
        self.labelLevel.color = UI.color.yellow
    elseif self.level < 45 then
        self.labelLevel.color = UI.color.red
    elseif self.level < 60 then
        self.labelLevel.color = UI.color.indigo
    elseif self.level < 75 then
        self.labelLevel.color = UI.color.mint
    elseif self.level < 90 then
        self.labelLevel.color = UI.color.green
    elseif self.level < 105 then
        self.labelLevel.color = UI.color.darkGray
    elseif self.level < 120 then
        self.labelLevel.color = UI.color.pink
    elseif self.level < 135 then
        self.labelLevel.color = UI.color.teal
    elseif self.level < 150 then
        self.labelLevel.color = UI.color.blue
    else
        self.labelLevel.color = UI.color.orange
    end
    if self.labelLevel.bitmapProperties then
        self.labelLevel.bitmapProperties.img = nil
    end
    if self.level <= maxLevel then
        self.img.s = math.pow(1.01, self.level - 1)
    end

    -- FIRE
    if self.inputStrength.fire >= 0.5 or self.autoFire then
        for _, a in ipairs(self.accessories) do
            a:fire()
            a.reloadTime = a.reloadTime + dt
        end
    end

    -- OBJECTS
    for _, o in pairs(self.objects) do
        o:update(dt)
    end

    -- ROTATION
    if self.autoSpin then
        self.tx, self.ty = utils.rotateBy(0, 60, -ar)
    else
        if mx and my then
            self.tx, self.ty = mx, my
        end
    end
    self.img.r = math.atan2(self.tx, self.ty)
    self.extra.r = -self.img.r

    -- MOVEMENT
    local ax, ay = utils.clampLength(
        (self.inputStrength.right - self.inputStrength.left) * self.stats.movementSpeed * 60,
        (self.inputStrength.up - self.inputStrength.down) * self.stats.movementSpeed * 60, 0,
        self.stats.movementSpeed * 60)
    self.vx, self.vy = self.vx + (ax * dt), self.vy + (ay * dt)
    self.img.x, self.img.y = self.img.x + (self.vx * dt), self.img.y + (self.vy * dt)
    self.vx, self.vy = utils.damp(self.vx, 0, 5, dt), utils.damp(self.vy, 0, 5, dt)

    -- MAP COLLISION
    if self.img.x > MAPSIZE then
        self.img.x = MAPSIZE
    elseif self.img.x < -MAPSIZE then
        self.img.x = -MAPSIZE
    end
    if self.img.y > MAPSIZE then
        self.img.y = MAPSIZE
    elseif self.img.y < -MAPSIZE then
        self.img.y = -MAPSIZE
    end

    if self.health >= self.stats.maxHealth then
        self.healthBar.max.color[4] = 0
        self.healthBar.container.color[4] = 0
        self.healthBar.fillBar.color[4] = 0
    else
        self.healthBar.max.color[4] = 1
        self.healthBar.container.color[4] = 1
        self.healthBar.fillBar.color[4] = 1
    end
    self.health = self.health - (dt * 2)
    self.healthBar:update(self.health, self.stats.maxHealth)
    -- if self.name ~= "Spot C." then
    self.score = self.score + (#self.name * 10)
    -- end
end

function P:updateControls()
    if lvk.isDown(self.input.up) then
        self.inputStrength.up = 1
    else
        self.inputStrength.up = 0
    end
    if lvk.isDown(self.input.down) then
        self.inputStrength.down = 1
    else
        self.inputStrength.down = 0
    end
    if lvk.isDown(self.input.left) then
        self.inputStrength.left = 1
    else
        self.inputStrength.left = 0
    end
    if lvk.isDown(self.input.right) then
        self.inputStrength.right = 1
    else
        self.inputStrength.right = 0
    end
    if lvk.isDown(self.input.fire) then
        self.inputStrength.fire = 1
    else
        self.inputStrength.fire = 0
    end
    if lvk.isDown(self.input.autoSpin) then
        self.autoSpin = not self.autoSpin
    end
    if lvk.isDown(self.input.autoFire) then
        self.autoFire = not self.autoFire
    end
end

return P
