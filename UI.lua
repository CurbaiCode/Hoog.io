--[[
 --	UI.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local UI = {}

-- CONSTANTS
UI.DarkMode = false

-- FUNCTIONS
local function newColor(r1, g1, b1, r2, g2, b2, a1, a2)
    return function(ax)
        return (UI.DarkMode and r2) and { r2 / 255, g2 / 255, b2 / 255, ((ax or a2) or 1) } or
            { r1 / 255, g1 / 255, b1 / 255, ((ax or a1) or 1) }
    end
end

-- COLORS
UI.color = {
    red = newColor(255, 107, 119, 255, 117, 131),
    orange = newColor(255, 169, 107, 255, 172, 117),
    yellow = newColor(255, 243, 107, 255, 241, 117),
    lime = newColor(193, 255, 107, 200, 255, 117),
    green = newColor(119, 255, 107, 131, 255, 117),
    mint = newColor(107, 255, 169, 117, 255, 172),
    teal = newColor(107, 255, 243, 117, 255, 241),
    cyan = newColor(107, 193, 255, 117, 200, 255),
    blue = newColor(107, 119, 255, 117, 131, 255),
    indigo = newColor(169, 107, 255, 172, 117, 255),
    purple = newColor(243, 107, 255, 241, 117, 255),
    pink = newColor(255, 107, 193, 255, 117, 200),
    black = newColor(58, 58, 60),
    white = newColor(242, 242, 247),
    darkerGray = newColor(72, 72, 74),
    darkGray = newColor(142, 142, 147),
    gray = newColor(174, 174, 178, 44, 44, 46),
    lightGray = newColor(209, 209, 214, 72, 72, 74),
    minimap = newColor(242, 242, 247, 99, 99, 102, 0.5, 0.5),
    grid = newColor(0, 0, 0, 0, 0, 0, 0.12, 0.16)
}

return UI
