--[[
 -- player.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local JSON = require("dkjson")
local GVG = require("GVG")
local UI = require("UI")
local utils = require("utils")

local P = {}

-- SHORTCUTS
local lvk = love.keyboard
local lvf = love.filesystem

-- CONSTANTS
local radius = 1

-- INIT
local blueprints = JSON.decode((lvf.read("blueprints/index.json")))

-- FUNCTIONS
local function construct(player, color, type)
    type = (type ~= "") and type or blueprints.default
    player.userData.tank = type
    local blueprint = JSON.decode((lvf.read("blueprints/" .. string.gsub(type:lower(), "%s", "-") .. ".json")))

    for i = #blueprint.accessories, 1, -1 do
        local a = blueprint.accessories[i]
        local plan = JSON.decode((lvf.read("blueprints/parts/" .. a.type .. ".json")))
        local part = GVG.Shape(plan.shape)
        part.color = UI.color.darkGray()
        part.r = utils.degToRad(a.angle)
        if plan.shape == "strip" then
            part.uniforms.point1[1] = { a.position[1], 0 }
            part.uniforms.point2[1] = { a.position[1], a.position[2] + radius + plan.length }
            part.uniforms.width[1] = plan.width
        elseif plan.shape == "trapezoid" then
            part.uniforms.base1[1] = plan.width / 2
            part.uniforms.base2[1] = plan.base / 2
            part.uniforms.height[1] = (radius + plan.length) / 2
            part.y = (radius + plan.length) / 2
        end
        part:createMesh()
        part:compileShader("baseF.glsl")
        player:add(part)
    end

    player.userData.body = GVG.Shape(blueprint.body)
    player.userData.body.color = player.userData.invincible and UI.color.darkGray() or color
    player.userData.body.uniforms.radius[1] = radius
    player.userData.body:createMesh()
    player.userData.body:compileShader("baseF.glsl")
    player:add(player.userData.body)

    player.userData.extra = GVG.Group()
    player:add(player.userData.extra)

    local name = GVG.Text(player.userData.name)
    name.mode = "software"
    name.softwareProperties = { scaleCorrection = false }
    name.snapToPixel = true
    name.size = 1
    name.font = "fonts/Now-Bold.otf"
    name.y = 2
    player.userData.extra:add(name)
end

-- MAIN
function P.New(x, y, keys, color, name)
    local player = GVG.Group(nil, x, y)
    player.userData.invincible = true
    player.userData.vx, player.userData.vy = 0, 0
    player.userData.color = color
    player.userData.tank = ""
    player.userData.name = name
    player.userData.keys = keys
    player.userData.controls = {
        up = 0,
        down = 0,
        left = 0,
        right = 0
    }

    construct(player, player.userData.color, player.userData.tank)
    return player
end

function P.import(playerData)
    local player = GVG.Group(nil, playerData.x, playerData.y)
    playerData.x, playerData.y = nil, nil
    for k, v in pairs(playerData) do
        player.userData[k] = v
    end

    construct(player, player.userData.color, player.userData.tank)
    return player
end

function P.update(players, mx, my, dt)
    for _, p in ipairs(players) do
        local horizontal, vertical = p.userData.controls.right - p.userData.controls.left,
            p.userData.controls.up - p.userData.controls.down

        if horizontal ~= 0 or vertical ~= 0 then
            p.userData.invincible = false
            p.userData.body.color = p.userData.color
        end

        -- ROTATION
        p.r = math.atan2(mx, my)
        p.userData.extra.r = -p.r

        -- MOVEMENT
        local maxSpeed = 12
        local lambda = -60 * math.log(0.985, 2)
        local dx, dy = utils.clampLength(horizontal, vertical, 0, 1)
        local ax, ay = dx * 0.5, dy * 0.5
        p.userData.vx, p.userData.vy = utils.damp(p.userData.vx, 0, lambda, dt), utils.damp(p.userData.vy, 0, lambda, dt)
        p.userData.vx, p.userData.vy = utils.clampLength(p.userData.vx + ax, p.userData.vy + ay, 0, maxSpeed)
        p.x, p.y = p.x + (p.userData.vx * dt), p.y + (p.userData.vy * dt)
    end
end

function P.updateControls(players)
    for _, p in ipairs(players) do
        p.userData.controls.up = lvk.isDown(p.userData.keys.up) and 1 or 0
        p.userData.controls.down = lvk.isDown(p.userData.keys.down) and 1 or 0
        p.userData.controls.left = lvk.isDown(p.userData.keys.left) and 1 or 0
        p.userData.controls.right = lvk.isDown(p.userData.keys.right) and 1 or 0
    end
end

return P
