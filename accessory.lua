--[[
 --	accessory.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local UI = require("UI")
local Object = require("object")
local utils = require("utils")

local A = {}

A.Accessory = class("Accessory")
function A.Accessory:init(owner, length, width, x, y, rotation, fireOffset)
    self.owner = owner
    self.length = self.owner.radius + length
    self.width = width
    self.stats = {
        fire = fireOffset,
        reload = 0,
        speed = 0,
        penetration = 0, -- Unused
        damage = 0,
        spread = 0
    }
    self.img = GVG.Group(nil, x, y, rotation)
end

function A.Accessory:fire(type)
    if self.reloadTime >= self.owner.stats.reload + self.stats.reload then
        self.reloadTime = 0
        local rotation = self.owner.img.r + self.img.r +
            ((math.random() - 0.5) * utils.degToRad(self.owner.stats.spread + self.stats.spread))
        local x, y = utils.rotateBy(self.img.x * self.owner.img.s, (self.length + self.img.y) * self.owner.img.s,
            self.owner.img.r + self.img.r)
        local vx, vy = math.sin(rotation) * (self.owner.stats.speed + self.stats.speed),
            math.cos(rotation) * (self.owner.stats.speed + self.stats.speed)
        local object = Object(self.owner, type, self.owner.img.x - x, self.owner.img.y + y, vx, vy,
            self.width * self.owner.img.s)
        self.owner.vx, self.owner.vy = self.owner.vx - (vx * 2), self.owner.vy - (vy * 2)
    end
end

-- ACCESSORIES
-- Cannon
A.Cannon = A.Accessory:extend("Cannon")
function A.Cannon:init(owner, type, x, y, rotation, fireOffset)
    self.super.init(self, owner, 22, 12, x, y, rotation, fireOffset)

    if type ~= "normal" then
        if type == "sniper" then
            self.length = self.length + 8 -- Exact
            self.stats.reload = 0.6
            self.stats.speed = 4
            self.stats.damage = 5
            self.stats.spread = -5
        end
    end

    local barrel = GVG.Shape("orientedBox")
    barrel.color = UI.color.darkGray
    barrel.uniforms.point1[1] = { 0, 0 }
    barrel.uniforms.point2[1] = { 0, self.length }
    barrel.uniforms.width[1] = self.width
    barrel.offset = OFFSET
    barrel:createMesh()
    barrel:compileShader()
    self.img:add(barrel)

    self.reloadTime = self.owner.stats.reload + self.stats.reload
end

function A.Cannon:fire()
    A.Accessory.fire(self, "bullet")
end

-- Launcher
A.Launcher = A.Accessory:extend("Launcher")
function A.Launcher:init(owner, type, x, y, rotation, fireOffset)
    self.super.init(self, owner, 16, 12, x, y, rotation, fireOffset)
    self.stats.penetration = self.stats.penetration * 2
    -- Inherited from Sniper Cannon
    self.stats.reload = 0.6
    self.stats.speed = 4
    self.stats.damage = 5
    self.stats.spread = -5

    -- if type ~= "normal" then

    -- end

    local container = GVG.Group()
    local barrel = GVG.Shape("orientedBox")
    barrel.color = UI.color.darkGray
    barrel.uniforms.point1[1] = { 0, 0 }
    barrel.uniforms.point2[1] = { 0, self.owner.radius + 2 }
    barrel.uniforms.width[1] = self.width
    barrel.offset = OFFSET
    barrel:createMesh()
    barrel:compileShader()
    local funnel = GVG.Shape("orientedBox")
    funnel.color = UI.color.darkGray
    funnel.uniforms.point1 = barrel.uniforms.point2
    funnel.uniforms.point2[1] = { 0, self.length }
    funnel.uniforms.width[1] = self.width + 16
    funnel.offset = OFFSET
    funnel:createMesh()
    funnel:compileShader()
    container:add(funnel)
    container:add(barrel)
    self.img:add(container)

    self.reloadTime = self.owner.stats.reload + self.stats.reload
end

function A.Launcher:fire()
    A.Accessory.fire(self, "trap")
end

return A
