path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

import CyclicList, Vec2 from M
import dot, wedge from Vec2
import clamp, sgn from M.math

geometry = {}

-- points are assumed to be Vec2

geometry.closest_edge_point = (P, A, B) ->
	u = B - A
    t = clamp(dot(P - A, u)/u\lenS(), 0, 1)
    return A + t*u

geometry.bounding_box = (points) ->
	minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
    for v in *points
        minx = math.min(minx, v.x)
        miny = math.min(miny, v.y)
        maxx = math.max(maxx, v.x)
        maxy = math.max(maxy, v.y)
    return {x:minx, y:miny}, {x:maxx, y:maxy}

geometry.is_point_in_triangle = (P, A, B, C) ->
    -- returns true if point is inside or on the boundary.
    -- result is exact for integer coordinates.
    sda = wedge(A - C, B - C) -- signed double area
    s = sgn(sda)
    a = wedge(P - C, B - C)
    b = wedge(P - C, C - A)
    return s*a >= 0 and s*b >=0 and s*(a + b) <= math.abs(sda)

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