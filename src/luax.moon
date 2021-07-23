path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

import Vec2 from M
import floor from math

local *

xtype = (x) ->
    t = type(x)
    if t ~= "table" then t
    else
        if cls = x.__class then cls else t

xmath = {}
M.math = xmath

xmath.sgn = (x) -> x > 0 and 1 or x < 0 and -1 or 0

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