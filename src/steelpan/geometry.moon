path = (...)\gsub("[^%.]*$", "")
CyclicList = require path .. 'cyclic'
Vec2 = require path .. 'vectors'
utils = require path .. 'utils'

import dot, wedge from Vec2
import clamp, sgn from utils.math
import min, max, abs, huge from math

geometry = {}

-- points are assumed to be Vec2

geometry.closest_edge_point = (P, A, B) ->
	u = B - A
    t = clamp(dot(P - A, u)/u\lenS(), 0, 1)
    return A + t*u

geometry.bounding_box = (points) ->
	minx, miny, maxx, maxy = huge, huge, -huge, -huge
    for v in *points
        minx = min(minx, v.x)
        miny = min(miny, v.y)
        maxx = max(maxx, v.x)
        maxy = max(maxy, v.y)
    return {x:minx, y:miny}, {x:maxx, y:maxy}

geometry.is_point_in_triangle = (P, A, B, C) ->
    -- returns true if point is inside or on the boundary.
    -- result is exact for integer coordinates.
    sda = wedge(A - C, B - C) -- signed double area
    s = sgn(sda)
    a = wedge(P - C, B - C)
    b = wedge(P - C, C - A)
    return s*a >= 0 and s*b >=0 and s*(a + b) <= abs(sda)

geometry.centroid = (points) ->
	P = CyclicList(points)
	W = 0
	C = Vec2()
	for i = 1, #points
		tmp = wedge(P[i], P[i + 1])
		W += tmp
		C += (P[i] + P[i + 1])*tmp
	return C/(3*W) 

return geometry