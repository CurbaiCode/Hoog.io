--[[
 -- main.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
package.path = package.path .. ";./dkjson/?.lua;./GVG-Lua/?.lua;./30log/?.lua;./uuid/src/?.lua"
local JSON = require("dkjson")
local GVG = require("GVG")
local UI = require("UI")
local Player = require("player")
local Network = require("networking")
local utils = require("utils")

-- SHORTCUTS
local lvg = love.graphics
local lvm = love.mouse
local lvf = love.filesystem

-- CONSTANTS
DEBUG = false
UI.DarkMode = false
local camera = nil
local scene = nil
local world = nil
local arena = nil
local map = nil
local player = nil
local owners = {
    Me = {
        players = {},
        objects = {},
        drones = {}
    }
}

-- MAIN
function love.load()
    math.randomseed(love.timer.getTime())

    -- INIT GVG
    GVG.init("GVG-Lua/baseF.glsl", "GVG-Lua/baseV.glsl")
    GVG.loadShapesFromDirectory("GVG-Lua/Shapes")
    GVG.loadHullsFromDirectory("GVG-Lua/Hulls")

    -- SCENE
    lvg.setBackgroundColor(UI.color.gray())
    camera = GVG.Group()
    scene = GVG.Group()
    world = GVG.Group()
    arena = GVG.Group()
    scene:add(world)
    scene:add(arena)
    camera:add(scene)
    camera.s = 30

    map = GVG.Shape("rectangle")
    map.color = UI.color.lightGray()
    map.uniforms.size[1] = { 60, 60 }
    map:createMesh()
    map:compileShader()
    world:add(map)

    -- local nest = GVG.Shape("rectangle")
    -- nest.color = UI.color.indigo()
    -- nest.uniforms.size[1] = { 20, 20 }
    -- nest:createMesh()
    -- nest:compileShader()
    -- world:add(nest)

    local grid = GVG.Shape("grid")
    grid.color = UI.color.grid()
    grid.stroke = 2
    grid.uniforms.spacing[1] = { 1, 1 }
    grid:createMesh()
    grid:compileShader()
    world:add(grid)

    -- NETWORKING
    Network.init()
    -- Network.connect()

    -- PLAYERS
    player = Player.New(math.random() * 60, math.random() * 60, { up = "w", down = "s", left = "a", right = "d" },
        UI.color.cyan(), "Software")
    table.insert(owners["Me"].players, player)
    for _, p in ipairs(owners["Me"].players) do
        arena:add(p)
    end
end

function love.mousemoved(x, y)

end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.keypressed()
    Player.updateControls(owners["Me"].players)
end

function love.keyreleased()
    Player.updateControls(owners["Me"].players)
end

function love.resize()

end

function love.update(dt)
    local result = Network.receive()
    while result do
        if result.type == "connect" then
            owners[result.peer:connect_id()] = {
                players = {},
                objects = {},
                drones = {}
            }
            Network.send(JSON.encode({ message = "request" }), result.peer)
        elseif result.type == "disconnect" then
            for _, p in ipairs(owners[result.peer:connect_id()].players) do
                p:delete()
            end
            owners[result.peer:connect_id()] = nil
        elseif result.type == "receive" then
            local newData = JSON.decode(result.data)
            if newData.message == "update" then
                for i, p in ipairs(newData.players) do
                    if owners[result.peer:connect_id()].players[i] then
                        owners[result.peer:connect_id()].players[i].x = p.x
                        owners[result.peer:connect_id()].players[i].y = p.y
                    end
                end
            elseif newData.message == "request" then
                local package = utils.copy(player.userData)
                package.keys = nil
                package.controls = nil
                package.x, package.y = player.x, player.y
                Network.send(JSON.encode({
                    message = "respond",
                    player = package
                }), result.peer)
            elseif newData.message == "respond" then
                local foreignPlayer = Player.import(newData.player)
                table.insert(owners[result.peer:connect_id()].players, foreignPlayer)
                arena:add(foreignPlayer)
            end
        end
        result = Network.receive()
    end
    Player.update(owners["Me"].players, dt)
    scene.x, scene.y = -player.x, -player.y
    local package = {}
    for _, p in ipairs(owners["Me"].players) do
        table.insert(package, { x = p.x, y = p.y })
    end
    Network.broadcast(JSON.encode({
        message = "update",
        players = package
    }))
end

function love.draw()
    camera:draw()
end
