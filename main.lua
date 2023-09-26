--[[
 --	main.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local utils = require("utils")
GVG = require("GVG.GVG")
local UI = require("UI")
local Player = require("player")
local Builder = require("builder")

-- SHORTCUTS
local lvg = love.graphics
local lvm = love.mouse
local lvf = love.filesystem

-- CONSTANTS
DEBUG = true
local margin = 16
WindowW = (lvg.getWidth() / 2) - margin
WindowH = (lvg.getHeight() / 2) - margin
MAPSIZE = 65 * 30
local mouseX, mouseY = 0, 0
local hostPlayer = nil
local players = {}
OFFSET = 4

-- MAIN
function love.load()
    -- GVG
    GVG.init(lvf.read("GVG/baseF.glsl"), lvf.read("GVG/baseV.glsl"))
    GVG.loadShapesFromDirectory("GVG/Shapes")
    GVG.loadHullsFromDirectory("GVG/Hulls")

    -- SCENE
    BG = GVG.Shape("square")
    BG.color = UI.color.gray
    BG:createMesh()
    BG:compileShader((lvf.read("GVG/baseF2.glsl")))

    SCENE = GVG.Group()
    MAPLayer = GVG.Group()
    PLAYERLayer = GVG.Group()
    OBJECTLayer = GVG.Group()
    OBSTACLELayer = GVG.Group() -- Unused
    SCENE:add(MAPLayer)
    SCENE:add(OBJECTLayer)
    SCENE:add(PLAYERLayer)
    SCENE:add(OBSTACLELayer)
    -- Map
    Map = GVG.Shape("square")
    Map.color = UI.color.lightGray
    -- Map.r = 0.5
    Map.uniforms.radius[1] = MAPSIZE
    Map.offset = 4
    Map:createMesh()
    Map:compileShader((lvf.read("GVG/baseF2.glsl")))
    MAPLayer:add(Map)

    local Grid = GVG.Shape("grid")
    Grid.color = UI.color.grid
    Grid.stroke = 2
    Grid.uniforms.spacing[1] = { 30, 30 }
    Grid:createMesh()
    Grid:compileShader()
    MAPLayer:add(Grid)

    -- PLAYERS
    hostPlayer = Player(0, 0, UI.color.cyan, "Spot C.", "circle", 0)
    hostPlayer.health = 75
    Builder.single(hostPlayer, "launcher", "normal")
    SCENE:add(hostPlayer.img)

    table.insert(players,
        Player(150, 150, UI.color.purple, "Les", "circle", 6507,
            { up = "y", down = "h", left = "g", right = "j", fire = "t", autoFire = "u", autoSpin = "m" }))
    table.insert(players,
        Player(-150, -150, UI.color.red, "Jack Kelly", "circle", 661,
            { up = "up", down = "down", left = "left", right = "right", fire = "p", autoFire = "o", autoSpin = "l" }))
    table.insert(players,
        Player(-150, 150, UI.color.green, "Jerry Spinelli", "circle", 0,
            { up = "y", down = "h", left = "g", right = "j", fire = "t", autoFire = "u", autoSpin = "m" }))
    table.insert(players,
        Player(150, -150, UI.color.indigo, "Developer", "circle", 24107,
            { up = "kp8", down = "kp5", left = "kp4", right = "kp6", fire = "kp0", autoFire = "kp9", autoSpin = "kp3" }))
    for i, p in ipairs(players) do
        if i == 4 then
            Builder.single(p, "cannon", "sniper")
        else
            Builder.single(p, "cannon", "normal")
        end
        PLAYERLayer:add(p.img)
    end

    -- HUD
    HUD = GVG.Group()
    BOARD = UI.Board(hostPlayer, players)
    MINIMAP = UI.Minimap()
    HUD:add(BOARD.img)
    HUD:add(MINIMAP.img)

    MINIMAP:populate(hostPlayer, players)
end

function love.mousemoved(x, y)
    mouseX, mouseY = GVG.screenToWorld(lvm.getPosition())
end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.keypressed()
    hostPlayer:updateControls()
    for _, p in ipairs(players) do
        p:updateControls()
    end
end

function love.keyreleased()
    hostPlayer:updateControls()
    for _, p in ipairs(players) do
        p:updateControls()
    end
end

function love.resize()
    WindowW = (lvg.getWidth() / 2) - margin
    WindowH = (lvg.getHeight() / 2) - margin
end

local fps = 0
local autoRotation = 0
function love.update(dt)
    fps = 1 / dt
    BG.uniforms.radius[1] = math.max(WindowW, WindowH) + (margin * 2)

    -- hostPlayer.level = hostPlayer.level + 1
    -- hostPlayer.stats.maxHealth = hostPlayer.stats.maxHealth + 0.1
    hostPlayer:update(dt, autoRotation, mouseX, mouseY)
    SCENE.s = 1 / hostPlayer.img.s
    for _, p in ipairs(players) do
        p:update(dt, autoRotation)
    end
    MINIMAP:update(hostPlayer, players)
    BOARD:update(hostPlayer, players)

    autoRotation = autoRotation + dt

    -- love.timer.sleep(1 / 30)
end

function love.draw()
    BG:draw()
    SCENE:draw(-(hostPlayer.img.x / hostPlayer.img.s), -(hostPlayer.img.y / hostPlayer.img.s))
    HUD:draw()

    if DEBUG then
        lvg.print("FPS: " .. ("%.2f"):format(fps)
            .. "\n\nHealth: " ..
            ("%.2f"):format(utils.clamp(hostPlayer.health / hostPlayer.stats.maxHealth, 0, 1) * 100) .. "%"
            .. "\nAutoFire: " .. (hostPlayer.autoFire and "True" or "False")
            .. "\nAutoSpin: " .. (hostPlayer.autoSpin and "True" or "False"), margin, margin)
    end
    local i = 0
    for k, v in pairs(hostPlayer.stats) do
        lvg.print(k .. ": " .. v, margin, (WindowH * 2) - (15 * i))
        i = i + 1
    end
end
