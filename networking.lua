--[[
 -- main.lua
 -- Hoog.io 0.4
 --
 -- Copyright (c) 2023 Curbai. All rights reserved.
--]]
local enet = require("enet")
local socket = require("socket")

local N = {}

-- CONSTANTS
local host = nil

-- MAIN
function N.init()
    host = assert(enet.host_create((socket.dns.toip(socket.dns.gethostname())) .. ":16473"))
end

function N.connect(ip)
    host:connect(ip .. ":16473")
end

function N.broadcast(data)
    host:broadcast(data)
end

function N.send(data, target)
    target:send(data)
end

function N.receive(timeout)
    return timeout and host:service(timeout) or host:service()
end

return N
