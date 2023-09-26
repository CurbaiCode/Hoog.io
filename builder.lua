--[[
 --	builder.lua
 -- Hoog.io 0.3
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local utils = require("utils")
local Accessory = require("accessory")

local B = {}

-- FUNCTIONS
-- Distribute points between a range that is centered on 0: e.g. if range is 200, values are between 100 and -100
local function centered(i, n, t) -- (item number, number of items, total space or range)
    return i * (t / n) - ((t / n) * ((n + 1) / 2))
end

local function addAccessory(p, t, s, x, y, r, fo)
    if t == "cannon" then
        p:add("accessory", Accessory.Cannon(p, s, x, y, r, fo))
    elseif t == "launcher" then
        p:add("accessory", Accessory.Launcher(p, s, x, y, r, fo))
    end
end

-- MAIN
function B.single(player, type, subtype)
    addAccessory(player, type, subtype, 0, 0, 0, 0)
end

function B.parallel(player, amount, type, subtype)
    for i = amount, 1, -1 do
        addAccessory(player, type, subtype, centered(i, amount, player.radius * 2), 0, 0, 1 / amount)
    end
end

function B.star(player, amount, type, subtype)
    for i = 1, amount do
        local angle = utils.degToRad((i / amount) * 360)
        addAccessory(player, type, subtype, 0, 0, angle, 0)
    end
end

return B
