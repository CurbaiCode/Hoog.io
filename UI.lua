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
    return function()
        return (UI.DarkMode and r2) and { r2 / 255, g2 / 255, b2 / 255, (a2 or 1) } or
            { r1 / 255, g1 / 255, b1 / 255, (a1 or 1) }
    end
end

-- COLORS
UI.color = {
    red = newColor(255, 59, 48, 255, 69, 58),
    orange = newColor(255, 149, 0, 255, 159, 10),
    yellow = newColor(255, 204, 0, 255, 214, 10),
    green = newColor(40, 205, 65, 50, 215, 75),
    mint = newColor(0, 199, 190, 102, 212, 207),
    teal = newColor(89, 173, 196, 106, 196, 220),
    cyan = newColor(85, 190, 240, 90, 200, 245),
    blue = newColor(0, 122, 255, 10, 132, 255),
    indigo = newColor(88, 86, 214, 94, 92, 230),
    purple = newColor(175, 82, 222, 191, 90, 242),
    pink = newColor(255, 45, 85, 255, 55, 95),
    brown = newColor(162, 132, 94, 172, 142, 104),
    black = newColor(58, 58, 60),
    white = newColor(242, 242, 247),
    darkerGray = newColor(72, 72, 74),
    darkGray = newColor(142, 142, 147),
    gray = newColor(174, 174, 178, 58, 58, 60),
    lightGray = newColor(199, 199, 204, 72, 72, 74),
    minimap = newColor(242, 242, 247, 99, 99, 102, 0.5, 0.5),
    grid = newColor(0, 0, 0, 0, 0, 0, 0.12, 0.16)
}

return UI
