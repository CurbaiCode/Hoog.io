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
    red = newColor(255, 82, 96, 255, 92, 108),
    orange = newColor(255, 154, 82, 255, 157, 92),
    yellow = newColor(255, 241, 82, 255, 239, 92),
    lime = newColor(183, 255, 82, 190, 255, 92),
    green = newColor(96, 255, 82, 108, 255, 92),
    mint = newColor(82, 255, 154, 92, 255, 157),
    teal = newColor(82, 255, 241, 92, 255, 239),
    cyan = newColor(82, 183, 255, 92, 190, 255),
    blue = newColor(82, 96, 255, 92, 108, 255),
    indigo = newColor(154, 82, 255, 157, 92, 255),
    purple = newColor(241, 82, 255, 239, 92, 255),
    pink = newColor(255, 82, 183, 255, 92, 190),
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
