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
local myIP = (socket.dns.toip(socket.dns.gethostname()))

-- MAIN
function N.init()
    host = assert(enet.host_create(myIP .. ":16473"))
end

function N.connect(ip)
    if ip ~= myIP then
        local peers = N.getPeers()
        if not peers[ip] then
            host:connect(ip .. ":16473")
        end
    end
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

function N.getPeers()
    local peers = {}
    for i = 1, host:peer_count() do
        local address = tostring(host:get_peer(i)):match("^(.*):")
        if address ~= "0.0.0.0" and address ~= myIP then
            peers[address] = true
        end
    end
    return peers
end

return N
