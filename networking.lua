--[[
 -- main.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local enet = require("enet")

local N = {}

-- CONSTANTS
local socket = nil

-- MAIN
function N.init(ip)
    socket = assert(enet.host_create(ip .. ":16473"))
end

function N.connect(ip)
    socket:connect(ip .. ":16473")
end

function N.broadcast(data)
    socket:broadcast(data)
end

function N.send(data, target)
    target:send(data)
end

function N.receive(timeout)
    return timeout and socket:service(timeout) or socket:service()
end

return N
