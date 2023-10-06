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
        end
        part:createMesh()
        part:compileShader()
        player:add(part)
    end

    local body = GVG.Shape(blueprint.body)
    body.color = color
    body.uniforms.radius[1] = radius
    body:createMesh()
    body:compileShader()
    player:add(body)
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
        -- ROTATION
        p.r = math.atan2(mx, my)

        -- MOVEMENT
        local ax, ay = utils.clampLength((p.userData.controls.right - p.userData.controls.left),
            (p.userData.controls.up - p.userData.controls.down), 0, 0.02)
        p.userData.vx, p.userData.vy = p.userData.vx + ax, p.userData.vy + ay
        p.x, p.y = p.x + p.userData.vx, p.y + p.userData.vy
        p.userData.vx, p.userData.vy = utils.damp(p.userData.vx, 0, 4, dt), utils.damp(p.userData.vy, 0, 4, dt)
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
