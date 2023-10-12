--[[
 -- main.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
package.path = package.path .. ";" .. arg[1] .. "/dkjson/?.lua"
package.path = package.path .. ";" .. arg[1] .. "/GVG-Lua/?.lua;" ..
    arg[1] .. "/30log/?.lua;" .. arg[1] .. "/uuid/src/?.lua"
local JSON = require("dkjson")
local GVG = require("GVG")
local UI = require("UI")
local Player = require("player")
local Network = require("networking")
local utils = require("utils")

-- SHORTCUTS
local lvg = love.graphics
local lvm = love.mouse

-- CONSTANTS
DEBUG = false
UI.DarkMode = false
local mouseX, mouseY = 0, 0
local camera = nil
local scene = nil
local world = nil
local arena = nil
local zone = nil
local map = nil
local player = nil
local owners = {
    Me = {
        players = {},
        previous = {},
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
    zone = GVG.Group()
    scene:add(world)
    scene:add(arena)
    scene:add(zone)
    camera:add(scene)

    map = GVG.Shape("rectangle")
    map.color = UI.color.lightGray()
    map.uniforms.size[1] = { 50, 50 }
    map:createMesh()
    map:compileShader()
    world:add(map)

    local nest = GVG.Shape("rectangle")
    nest.color = UI.color.indigo(0.4)
    nest.uniforms.size[1] = { 20, 20 }
    nest:createMesh()
    nest:compileShader()
    world:add(nest)

    local cyanBase = GVG.Shape("rectangle")
    cyanBase.color = UI.color.cyan(0.4)
    cyanBase.uniforms.size[1] = { 10, 10 }
    cyanBase.x, cyanBase.y = -40, 40
    cyanBase:createMesh()
    cyanBase:compileShader()
    world:add(cyanBase)

    local greenBase = GVG.Shape("rectangle")
    greenBase.color = UI.color.green(0.4)
    greenBase.uniforms.size[1] = { 10, 10 }
    greenBase.x, greenBase.y = -40, -40
    greenBase:createMesh()
    greenBase:compileShader()
    world:add(greenBase)

    local redBase = GVG.Shape("rectangle")
    redBase.color = UI.color.red(0.4)
    redBase.uniforms.size[1] = { 10, 10 }
    redBase.x, redBase.y = 40, -40
    redBase:createMesh()
    redBase:compileShader()
    world:add(redBase)

    local pinkBase = GVG.Shape("rectangle")
    pinkBase.color = UI.color.pink(0.4)
    pinkBase.uniforms.size[1] = { 10, 10 }
    pinkBase.x, pinkBase.y = 40, 40
    pinkBase:createMesh()
    pinkBase:compileShader()
    world:add(pinkBase)

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
    player = Player.New((math.random() - 0.5) * 50, (math.random() - 0.5) * 50,
        { up = "w", down = "s", left = "a", right = "d" },
        UI.color.cyan(), "Dev")
    table.insert(owners["Me"].players, player)
    for _, p in ipairs(owners["Me"].players) do
        zone:add(p)
    end

    love.resize()
end

function love.mousemoved(x, y)
    mouseX, mouseY = GVG.screenToWorld(lvm.getPosition())
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
    camera.s = math.sqrt((lvg.getWidth() * lvg.getHeight()) / 2304)
end

function love.update(dt)
    local result = Network.receive()
    while result do
        if result.type == "connect" then
            owners[result.peer:index()] = {
                players = {},
                objects = {},
                drones = {}
            }
            Network.send(JSON.encode({ message = "connect", connections = Network.getPeers() }), result.peer)
        elseif result.type == "disconnect" then
            if owners[result.peer:index()] then
                for _, p in ipairs(owners[result.peer:index()].players) do
                    p:delete()
                end
                owners[result.peer:index()] = nil
            end
        elseif result.type == "receive" then
            local newData = JSON.decode(result.data)
            if newData.message == "connect" then
                for ip, _ in pairs(newData.connections) do
                    Network.connect(ip)
                end
                Network.send(JSON.encode({ message = "connected" }), result.peer)
            elseif newData.message == "connected" then
                Network.send(JSON.encode({ message = "request" }), result.peer)
            elseif newData.message == "request" then
                local playersData = {}
                for _, p in ipairs(owners["Me"].players) do
                    local playerData = utils.copy(p.userData)
                    playerData.keys = nil
                    playerData.controls = nil
                    playerData.x, playerData.y, playerData.r = p.x, p.y, p.r
                    table.insert(playersData, playerData)
                end
                Network.send(JSON.encode({
                    message = "respond",
                    players = playersData
                }), result.peer)
            elseif newData.message == "respond" then
                for _, p in ipairs(newData.players) do
                    local foreignPlayer = Player.import(p)
                    table.insert(owners[result.peer:index()].players, foreignPlayer)
                    arena:add(foreignPlayer)
                end
            elseif newData.message == "update" then
                for i, p in ipairs(newData.players) do
                    if owners[result.peer:index()].players[i] then
                        owners[result.peer:index()].players[i].x = p.x or owners[result.peer:index()].players[i].x
                        owners[result.peer:index()].players[i].y = p.y or owners[result.peer:index()].players[i].y
                        owners[result.peer:index()].players[i].r = p.r or owners[result.peer:index()].players[i].r
                    end
                end
            end
        end
        result = Network.receive()
    end
    Player.update(owners["Me"].players, mouseX, mouseY, dt)
    scene.x, scene.y = -player.x, -player.y
    local playersInfo = {}
    for i, p in ipairs(owners["Me"].players) do
        local playerInfo = {}
        if not owners["Me"].previous[i].x then
            owners["Me"].previous[i].x = 0
        end
        if not owners["Me"].previous[i].y then
            owners["Me"].previous[i].y = 0
        end
        if not owners["Me"].previous[i].r then
            owners["Me"].previous[i].r = 0
        end
        if owners["Me"].previous[i].x ~= p.x then
            playerInfo.x = p.x
            owners["Me"].previous[i].x = p.x
        end
        if owners["Me"].previous[i].y ~= p.y then
            playerInfo.y = p.y
            owners["Me"].previous[i].y = p.y
        end
        if owners["Me"].previous[i].r ~= p.r then
            playerInfo.r = p.r
            owners["Me"].previous[i].r = p.r
        end
        table.insert(playersInfo, playerInfo)
    end
    Network.broadcast(JSON.encode({
        message = "update",
        players = playersInfo
    }))
end

function love.draw()
    camera:draw()
end
