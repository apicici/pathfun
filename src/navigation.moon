-- The 'shortest_path' and 'string_pull' functions are based on C++ code from the Godot Engine.
-- Original copyright reported below:

---------------------------------------------------------------------------
--  navigation_2d.cpp                                                    --
---------------------------------------------------------------------------
--                       This file is part of:                           --
--                           GODOT ENGINE                                --
--                      https://godotengine.org                          --
---------------------------------------------------------------------------
-- Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur.                 --
-- Copyright (c) 2014-2021 Godot Engine contributors (cf. AUTHORS.md).   --
--                                                                       --
-- Permission is hereby granted, free of charge, to any person obtaining --
-- a copy of this software and associated documentation files (the       --
-- "Software"), to deal in the Software without restriction, including   --
-- without limitation the rights to use, copy, modify, merge, publish,   --
-- distribute, sublicense, and/or sell copies of the Software, and to    --
-- permit persons to whom the Software is furnished to do so, subject to --
-- the following conditions:                                             --
--                                                                       --
-- The above copyright notice and this permission notice shall be        --
-- included in all copies or substantial portions of the Software.       --
--                                                                       --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       --
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    --
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.--
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  --
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  --
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     --
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                --
---------------------------------------------------------------------------



path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'main')

import Class, CyclicList, Set, Vec2 from M.steelpan
import SymmetricMatrix from M.steelpan.matrices
import bounding_box, centroid, closest_edge_point, is_point_in_triangle from M.steelpan.geometry
import round, clamp, sgn from M.steelpan.utils.math
import dot, wedge from Vec2
import huge from math

unpack = unpack or table.unpack

local *

ConvexPolygon = Class {
    __init: (vertices, @name, @hidden) =>
        -- vertices is a list of Vec2
        assert(#vertices > 2, "A polygon must have a least 3 points.")
        @vertices = CyclicList(vertices)
        @n = #vertices
        @min, @max = bounding_box(vertices)
        @centroid = centroid(vertices)
        @connections = {}

    ipairs: => ipairs(@vertices.items)

    __index: (key) => type(key) == "number" and @vertices[key] or nil

    get_edge: (i) => @vertices[i], @vertices[i + 1]

    get_connection: (i) =>
        -- if edge i is connected to another polygon return the polygon + edge_idx it is connected to
        -- if connected to multiple polygons return the first non-hidden one
        if c = @connections[i]
            for t in *c
                if not t.polygon.hidden
                    return t

    is_point_inside: (P) =>
        unless P.x < @min.x or P.y < @min.y or P.x > @max.x or P.y > @max.y
            for i = 2, @n - 1
                if is_point_in_triangle(P, @vertices[1], @vertices[i], @vertices[i + 1]) then return true
        return false

    is_point_inside_connected: (P, visited={}) =>
        visited[self] = true
        if @is_point_inside(P)
            return self
        for i = 1, @n
            if c = @get_connection(i)
                p = c.polygon
                if not visited[p]
                    if poly = p\is_point_inside_connected(P, visited)
                        return poly

    closest_edge_point: (P, edge_idx) =>
        A, B = @get_edge(edge_idx)
        return closest_edge_point(P, A, B)

    closest_boundary_point_connected: (P, visited={}) =>
        visited[self] = true

        local C, poly
        d = huge
        -- cycle through edges
        for i = 1, @n
            local tmp_C, tmp_poly
            tmp_d = huge

            if neighbour = @get_connection(i)
                neighbour = neighbour.polygon
                if not visited[neighbour]
                    tmp_C, tmp_poly, tmp_d = neighbour\closest_boundary_point_connected(P, visited)
            else
                tmp_poly = self
                tmp_C = @closest_edge_point(P, i)
                tmp_d = (P - tmp_C)\lenS()

            if tmp_d < d
                C, poly, d = tmp_C, tmp_poly, tmp_d
        
        return C, poly, d
}


Navigation = Class {
    __init: (pmaps={}) =>
        -- pmaps is a table of lists of convex decompositions. Each convex decomposition is a list
        -- of convex polygons, represented by a list of pairs of coordinates. Each pmap can optionally have
        -- a "name" field (a string), which will be used to toggle the pmap visibility, and a "hidden" field
        -- (boolean) which will determine if it is initially visible.
        --
        -- scaling_regions is a table of convex decomposition. Each scaling region must have a "grad_start"
        -- and a "grad_end" field (both pairs of coordinates) and a "scale_table" field. The "scale_table"
        -- field is a list of pairs {a, scale} where "a" is a parameter between 0 and 1 specifying the position
        -- on the segment with endpoints grad_start and grad_end, while "scale" specifies the scaling percentage
        -- at that point (betwen 0 and 1). The entries of the scale table should be ordered by the parameter "a"
        -- and contain at least the a=0 and a=1 entries.
        vertices, vertex_idxs, polygons, name_groups = {}, {n:0}, {}, {}
        for pmap in *pmaps
            name_group = pmap.name and {}
            name_groups[pmap.name] = name_group if pmap.name
            for poly in *pmap
                tmp = {}
                for v in *poly
                    x, y = unpack(v)
                    label = tostring(x) .. ';' .. tostring(y)
                    if not vertices[label]
                        v = Vec2(x, y)
                        vertices[label] = v
                        vertex_idxs.n += 1
                        vertex_idxs[v] = vertex_idxs.n
                    tmp[#tmp + 1] = vertices[label]
                cp = ConvexPolygon(tmp, pmap.name, pmap.hidden)
                polygons[#polygons + 1] = cp
                name_group[#name_group + 1] = cp if name_group

        @polygons = polygons
        @vertex_idxs = vertex_idxs
        @name_groups = name_groups

    set_visibility: (name, bool) =>
        if t = @name_groups[name]
            for p in *t
                p.hidden = not bool

    toggle_visibility: (name) =>
        if t = @name_groups[name]
            for p in *t
                p.hidden = not p.hidden

    initialize: =>
        @initialized = true
        edges_matrix = SymmetricMatrix(@vertex_idxs.n)
        for p in *@polygons
            for i = 1, p.n
                A, B = p\get_edge(i)
                A_idx, B_idx = @vertex_idxs[A], @vertex_idxs[B]
                t = edges_matrix\get(A_idx, B_idx)
                if not t
                    t = {}
                    edges_matrix\set(A_idx, B_idx, t)
                t[#t + 1] = {edge:i, polygon:p}

        for i = 1, @vertex_idxs.n
            for j = i + 1, @vertex_idxs.n
                if t = edges_matrix\get(i, j)
                    if #t > 1
                        for k, c in ipairs(t)
                            c.polygon.connections[c.edge] = [t[x] for x = 1, #t when x ~= k]

    _is_point_inside: (P) =>
        @initialize() if not @initialized
        for poly in *@polygons
            if not poly.hidden and poly\is_point_inside(P)
                return poly

    _closest_boundary_point: (P) =>
        @initialize() if not @initialized
        d = huge
        local C, poly
        for p in *@polygons
            unless p.hidden
                for i = 1, p.n
                    if not p\get_connection(i)
                        tmp_C = p\closest_edge_point(P, i)
                        tmp_d = (P - tmp_C)\lenS()
                        if tmp_d < d
                            d, C, poly = tmp_d, tmp_C, p

        return C, poly

    _shortest_path: (A, B) =>
        @initialize() if not @initialized
        if @n == 0
            return {}
        
        -- work with integer coordinates
        A, B = round(A), round(B)

        local node_A, node_B

        -- find piece and node cointaining A, or closest alternative
        node_A = @_is_point_inside(A)
        if not node_A
            A, node_A = @_closest_boundary_point(A)
            A = round(A)

        -- find node containing B, or closest alternative (only within nodes connected to 'node_A')
        node_B = node_A\is_point_inside_connected(B)
        if not node_B
            B, node_B = node_A\closest_boundary_point_connected(B)
            B = round(B)

        if A == B
            return {A}
        elseif node_A == node_B
            return {A, B}

        found_path = false

        for p in *@polygons
            p.prev_edge = nil

        polylist = Set()

        node_B.entry = B
        node_B.distance = 0
        polylist\add(node_B)

        while not found_path
            if polylist\size() == 0
                break
            local least_cost_poly
            least_cost = huge

            for p in polylist\iterator()
                cost = p ~= node_B and p.distance + (p.centroid - A)\len() or 0
                if cost < least_cost
                    least_cost_poly = p
                    least_cost = cost

            p = least_cost_poly
            for i = 1, p.n
                if t = p\get_connection(i)
                    q, c_edge = t.polygon, t.edge
                    entry = p\closest_edge_point(p.entry, i)
                    distance = p.distance + (p.entry - entry)\len()
                    if q.prev_edge
                        if q.distance > distance
                            q.prev_edge = c_edge
                            q.distance = distance
                            q.entry = entry
                    else
                        q.prev_edge = c_edge
                        q.distance = distance
                        q.entry = entry
                        polylist\add(q)
                        if q == node_A
                            found = true
                            break
            if found_path
                break
            polylist\remove(p)

        -- string pulling to optimise the path
        portals = {{A, A}}
        p = node_A
        while p ~= node_B and p.prev_edge
            C, D = p\get_edge(p.prev_edge)
            L, R = unpack(portals[#portals])
            sign = orientation(C, L, D)
            sign = sign == 0 and orientation(C, R, D) or sign 
            portals[#portals + 1] = sign > 0 and {C, D} or {D, C}
            if c = p\get_connection(p.prev_edge)
                p = c.polygon
        portals[#portals + 1] = {B, B}

        return string_pull(portals)

    is_point_inside: (x, y) =>
        return not not @_is_point_inside(Vec2(x, y))

    closest_boundary_point: (x, y) =>
        P = @_closest_boundary_point(Vec2(x, y))
        return P.x, P.y

    shortest_path: (x1, y1, x2, y2) =>
        path = @_shortest_path(Vec2(x1, y1), Vec2(x2, y2))
        path = [{v.x, v.y} for v in *path]
        return path
}
M.Navigation = Navigation

string_pull = (portals) ->
    portal_left, portal_right = unpack(portals[1])
    l_idx, r_idx = 1, 1
    apex = portal_left
    path = {apex}

    i = 1
    while i < #portals
        i += 1
        left, right = unpack(portals[i])

        skip = false
        -- update right
        if orientation(portal_right, apex, right) <= 0
            if apex == portal_right or orientation(portal_left, apex, right) > 0
                -- tighten the funnel
                portal_right = right
                r_idx = i
            else
                if path[#path] ~= portal_left
                    path[#path + 1] = portal_left
                apex = portal_left
                portal_right = apex 
                r_idx = l_idx
                i = l_idx
                skip = true

        -- update left
        if not skip and orientation(portal_left, apex, left) >= 0
            if apex == portal_left or orientation(portal_right, apex, left) < 0
                -- tighten the funnel
                portal_left = left
                l_idx = i
            else
                if path[#path] ~= portal_right
                    path[#path + 1] = portal_right
                apex = portal_right
                portal_left = apex 
                l_idx = r_idx
                i = r_idx

    A = portals[#portals][1]
    if path[#path] ~= A or #path == 1
        path[#path + 1] = A

    return path

orientation = (L, P, R) ->
    -- positive if L is to the left of P and R is to the right
    wedge(R - P, L - P)