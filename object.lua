--[[
 --	main.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local utils = require("utils")

-- FUNCTIONS
-- Compute fade
local function getFade(h)
    return h <= 0 and ((h + 0.15) / 0.15) or 1
end

-- MAIN
local Bullet, Trap
local O = class("Object")
function O:init(owner, type, x, y, vx, vy, radius)
    self.owner = owner
    self.vx, self.vy = vx, vy
    self.radius = radius
    self.stats = utils.copy(self.owner.stats)
    self.damping = 1
    self.rotate = false

    if type ~= nil then
        local aObject
        if type == "bullet" then
            self.damping = 0.99
            if not Bullet then
                Bullet = GVG.Shape("circle")
                Bullet.offset = OFFSET
                Bullet:createMesh()
                Bullet:compileShader()
            end
            aObject = GVG.Alias(Bullet)
        elseif type == "trap" then
            self.damping = 0.9
            self.radius = self.radius + 2
            self.rotate = true
            if not Trap then
                Trap = GVG.Shape("nstar")
                Trap.uniforms.points[1] = 3
                Trap.uniforms.inset[1] = 1 / 3
                Trap.offset = OFFSET
                Trap:createMesh()
                Trap:compileShader()
            end
            aObject = GVG.Alias(Trap)
        end
        aObject.properties.color = utils.copy(self.owner.color)
        aObject.x, aObject.y = x, y
        aObject.properties.uniforms = { radius = { self.radius } }
        self.owner.objects[aObject.uuid] = self
        OBJECTLayer:add(aObject)
        self.img = aObject
    end
end

function O:update(dt)
    self.img.x, self.img.y = self.img.x + self.vx, self.img.y + self.vy
    if self.rotate then
        self.img.r = self.img.r + (utils.length(self.vx, self.vy) / 24)
    end
    self.vx, self.vy = self.vx * self.damping, self.vy * self.damping
    self.img.s = self.img.s + (0.1 * (1 - getFade(self.stats.health)))
    self.img.properties.color[4] = getFade(self.stats.health)
    if self.stats.health > 0 and (self.img.x > MAPSIZE or self.img.x < -MAPSIZE or self.img.y > MAPSIZE or self.img.y < -MAPSIZE) then
        self.stats.health = 0
    else
        self.stats.health = self.stats.health - dt
    end
    if self.stats.health <= -0.15 then
        self:delete()
    end
end

function O:delete()
    self.img:delete()
    self.owner.objects[self.img.uuid] = nil
end

return O
