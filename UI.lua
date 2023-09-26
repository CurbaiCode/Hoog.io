--[[
 --	UI.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local class = require("30log")
local utils = require("utils")

local UI = {}

-- SHORTCUTS
local lvf = love.filesystem

-- CONSTANTS
DarkMode = false
local minimapScale = 18
local boardMax = 4

-- FUNCTIONS
local function newColor(r, g, b, a)
    return r / 255, g / 255, b / 255, (a or 1)
end

local function abbreviate(n)
    if n >= math.pow(10, 9) then
        return string.format("%.1fb", n / math.pow(10, 9))
    elseif n >= math.pow(10, 6) then
        return string.format("%.1fm", n / math.pow(10, 6))
    elseif n >= math.pow(10, 3) then
        return string.format("%.1fk", n / math.pow(10, 3))
    else
        return tostring(n)
    end
end

-- COLORS
do
    local colors = {
        red = DarkMode and { newColor(255, 69, 58) } or { newColor(255, 59, 48) },
        orange = DarkMode and { newColor(255, 159, 10) } or { newColor(255, 149, 0) },
        yellow = DarkMode and { newColor(255, 214, 10) } or { newColor(255, 204, 0) },
        green = DarkMode and { newColor(50, 215, 75) } or { newColor(40, 205, 65) },
        mint = DarkMode and { newColor(102, 212, 207) } or { newColor(0, 199, 190) },
        teal = DarkMode and { newColor(106, 196, 220) } or { newColor(89, 173, 196) },
        cyan = DarkMode and { newColor(90, 200, 245) } or { newColor(85, 190, 240) },
        blue = DarkMode and { newColor(10, 132, 255) } or { newColor(0, 122, 255) },
        indigo = DarkMode and { newColor(94, 92, 230) } or { newColor(88, 86, 214) },
        purple = DarkMode and { newColor(191, 90, 242) } or { newColor(175, 82, 222) },
        pink = DarkMode and { newColor(255, 55, 95) } or { newColor(255, 45, 85) },
        brown = DarkMode and { newColor(172, 142, 104) } or { newColor(162, 132, 94) },
        black = { newColor(58, 58, 60) },
        white = { newColor(242, 242, 247) },
        darkerGray = { newColor(72, 72, 74) },
        darkGray = { newColor(142, 142, 147) },
        gray = DarkMode and { newColor(58, 58, 60) } or { newColor(174, 174, 178) },
        lightGray = DarkMode and { newColor(72, 72, 74) } or { newColor(199, 199, 204) },
        minimap = DarkMode and { newColor(99, 99, 102, 0.5) } or { newColor(242, 242, 247, 0.5) },
        grid = DarkMode and { newColor(0, 0, 0, 0.16) } or { newColor(0, 0, 0, 0.12) }
        -- highlight = { newColor(242, 242, 247, 0.25) },
        -- shadow = { newColor(0, 0, 0, 0.33) },
        -- hover = { newColor(242, 242, 247, 0.1) }
    }

    UI.color = setmetatable({}, {
        __index = function(t, k)
            return utils.copy(colors[k])
        end
    })
end

-- CLASSES

-- BAR
local Bar, Container, Fill
UI.Bar = class("Bar")
function UI.Bar:init(x, y, height, full, fill, color, label)
    self.full = full
    self.fill = fill
    self.color = color
    self.img = GVG.Group(nil, x, y)

    self.max = GVG.Alias(Bar)
    self.max.uniforms.point1[1] = { -(self.full / 2), 0 }
    self.max.uniforms.point2[1] = { (self.full / 2), 0 }
    self.max.offset = height
    self.img:add(self.max)

    self.container = GVG.Shape("segment")
    self.container.color = UI.color.darkerGray
    self.container.uniforms.point1 = self.max.uniforms.point1
    self.container.uniforms.point2 = self.max.uniforms.point2
    self.container.offset = height - 2
    self.container:createMesh()
    self.container:compileShader((lvf.read("GVG/baseF2.glsl")))
    self.img:add(self.container)

    self.fillBar = GVG.Shape("segment")
    self.fillBar.color = self.color
    self.fillBar.uniforms.point1[1] = { -(self.full / 2), 0 }
    self.fillBar.uniforms.point2[1] = { self.fill - (self.full / 2), 0 }
    self.fillBar.offset = height - 2
    self.fillBar:createMesh()
    self.fillBar:compileShader((lvf.read("GVG/baseF2.glsl")))
    self.img:add(self.fillBar)

    if label ~= nil then
        self.label = GVG.Text(label, nil, 10, "bitmapsdf")
        self.img:add(self.label)
    end
end

function UI.Bar:update(fill, full, color, label)
    self.full = full or self.full
    self.fill = utils.clamp(fill or self.fill, 0, self.full)
    self.color = color or self.color
    if self.label then
        self.label.text = label
        if self.label.bitmapProperties then
            self.label.bitmapProperties.img = nil
        end
    end

    self.max.uniforms.point1[1][1] = -(self.full / 2)
    self.max.uniforms.point2[1][1] = self.full / 2
    self.fillBar.uniforms.point1[1][1] = -(self.full / 2)
    self.fillBar.uniforms.point2[1][1] = self.fill - (self.full / 2)
    self.fillBar.color = self.color
end

-- BOARD
UI.Board = class("Board")
function UI.Board:init(hostPlayer, players)
    local sortedPlayers = utils.copy(players)
    table.insert(sortedPlayers, hostPlayer)
    table.sort(sortedPlayers, function(a, b) return a.score > b.score end)
    self.highest = sortedPlayers[1].score
    self.bars = {}
    Bar = GVG.Shape("segment")
    Bar.color = UI.color.black
    Bar:createMesh()
    Bar:compileShader((lvf.read("GVG/baseF2.glsl")))
    self.img = GVG.Group(nil, WindowW, WindowH)

    local label = GVG.Text("Scoreboard", nil, 26, "bitmapsdf", -110, -16)
    self.img:add(label)

    local barsImg = GVG.Group(nil, -110, -50)
    self.img:add(barsImg)

    for i, p in pairs(sortedPlayers) do
        if i <= boardMax then
            local bar = UI.Bar(0, -18 * (i - 1), 8, 200, (p.score / self.highest) * 200, p.color, p.name)
            table.insert(self.bars, bar)
            barsImg:add(bar.img)
        end
    end
end

function UI.Board:update(hostPlayer, players)
    self.img.x, self.img.y = WindowW, WindowH

    local sortedPlayers = utils.copy(players)
    table.insert(sortedPlayers, hostPlayer)
    table.sort(sortedPlayers, function(a, b) return a.score > b.score end)
    self.highest = sortedPlayers[1].score

    for i, b in ipairs(self.bars) do
        if i <= boardMax then
            local p = sortedPlayers[i]
            b:update((p.score / self.highest) * 200, 200, p.color, p.name .. " - " .. abbreviate(p.score))
        end
    end
end

-- MINIMAP
local Dot
UI.Minimap = class("Minimap")
function UI.Minimap:init()
    self.minimapSize = MAPSIZE / minimapScale
    self.dots = {}
    self.img = GVG.Group(nil, WindowW - self.minimapSize, -(WindowH - self.minimapSize))

    local minimapBG = GVG.Shape("square")
    minimapBG.color = UI.color.minimap
    minimapBG.r = Map.r
    minimapBG.uniforms.radius[1] = self.minimapSize + 2
    minimapBG.offset = OFFSET
    minimapBG:createMesh()
    minimapBG:compileShader()
    self.img:add(minimapBG)

    Dot = GVG.Shape("circle")
    Dot.uniforms.radius[1] = 2
    Dot.offset = OFFSET
    Dot:createMesh()
    Dot:compileShader()
end

function UI.Minimap:addDot(x, y, color)
    local aDot = GVG.Alias(Dot)
    table.insert(self.dots, aDot)
    self.img:add(aDot)
end

function UI.Minimap:populate(hostPlayer, players)
    local sortedPlayers = utils.copy(players)
    table.insert(sortedPlayers, hostPlayer)
    table.sort(sortedPlayers, function(a, b) return a.score > b.score end)

    for _, p in ipairs(sortedPlayers) do
        self:addDot(p.img.x, p.img.y, p.color)
    end
end

function UI.Minimap:update(hostPlayer, players)
    self.img.x, self.img.y = WindowW - self.minimapSize, -(WindowH - self.minimapSize)

    local sortedPlayers = utils.copy(players)
    table.insert(sortedPlayers, hostPlayer)
    table.sort(sortedPlayers, function(a, b) return a.score > b.score end)

    for i, p in ipairs(sortedPlayers) do
        local d = self.dots[i]
        d.x, d.y = p.img.x / minimapScale, p.img.y / minimapScale
        d.properties.color = p.color
    end
end

return UI
