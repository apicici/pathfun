path = (...)\gsub("[^%.]*$", "")
Vec2 = require path .. 'vectors'

status, mod = pcall(require, "love")
love = status and mod or nil

import min, max, floor, ceil, huge, abs from math

local *

xtype = (x) ->
    t = type(x)
    if t == "table"
        if cls = x.__class then return cls
    return t


xmath = {}

xmath.sgn = (x) -> x > 0 and 1 or x < 0 and -1 or 0

xmath.floor = (a) ->
    if xtype(a) == Vec2
        Vec2(floor(a.x), floor(a.y))
    else
        floor(a)

xmath.ceil = (a) ->
    if xtype(a) == Vec2
        Vec2(ceil(a.x), ceil(a.y))
    else
        ceil(a)

round = (a) ->
    if xtype(a) == Vec2
        Vec2(round(a.x), round(a.y))
    else
        floor(a + 0.5)
xmath.round = round

clamp = (a, min, max) ->
    if xtype(a) == Vec2
        Vec2(clamp(a.x, min, max), clamp(a.y, min, max))
    else
        (a < min and min) or (a > max and max) or a
xmath.clamp = clamp

xmath.max = (a, ...) ->
    M, idx = -huge, nil
    if type(a) == 'table'
        for i, v in pairs(a)
            if v > M
                M = v
                idx = i
        return M, idx if M > -huge
    else
        return max(a, ...)

xmath.min = (a, ...) ->
    m, idx = huge, nil
    if type(a) == 'table'
        for i, v in pairs(a)
            if v < m
                m = v
                idx = i
        m, idx if m < huge
    else
        min(a, ...)


simplify_path = (path) ->
    -- simplifies path to remove occurrences of "/../"
    -- path should be a valid relative or absolute path to a file
    t = {path\sub(1, 1) == "/" and "/" or nil}
    for x in path\gmatch("([^/]+)")
        if x ~= ".."
            t[#t + 1] = x
        else
            t[#t] = nil
    return table.concat(t, "/")

random_choice = (t) ->
    i = love.math.random(#t)
    return t[i]

return {
    math: xmath
    type: xtype
    :simplify_path
    :random_choice
}