local U = {}

function U.lerp(v1, v2, a)
    return (v1 * (1 - a)) + (v2 * a)
end

function U.damp(x, y, lambda, dt)
    return U.lerp(x, y, 1 - math.exp(-lambda * dt))
end

function U.length(x, y)
    local r = math.sqrt((x * x) + (y * y))
    return r == 0 and 1 or r
end

function U.clamp(v, l, h)
    return math.min(math.max(v, l), h)
end

function U.clampLength(x, y, l, h)
    local length = U.length(x, y)
    return (x / length) * U.clamp(length, l, h), (y / length) * U.clamp(length, l, h)
end

-- Deep copy a table
function U.copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[U.copy(k, s)] = U.copy(v, s) end
    return res --setmetatable(res, getmetatable(obj))
end

function U.degToRad(d)
    return d * math.pi / 180
end

return U
