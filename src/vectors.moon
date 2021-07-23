path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

local Vec2
Vec2 = M.class {
    __init: (x=0, y=0) => self.x, self.y = x, y

    __add: (u, v) -> 
        Vec2(u.x + v.x, u.y + v.y)

    __sub: (u, v) ->
        Vec2(u.x - v.x, u.y - v.y)

    __unm: => Vec2(-self.x, -self.y)

    __mul: (a, b) -> 
        if type(a) == "number"
            Vec2(a*b.x, a*b.y)
        elseif type(b) == "number"
            Vec2(b*a.x, b*a.y)
        else error("attempt to multiply a vector with a non-scalar value", 2)

    __div: (a) => @@(self.x/a, self.y/a)

    __eq: (u, v) -> u.x == v.x and u.y == v.y

    __tostring: (v) -> "(#{v.x}, #{v.y})"

    __index: (key) =>
        key == 1 and @x or key == 2 and @y or nil

    dot: (u, v) -> u.x*v.x + u.y*v.y

    wedge: (u, v) -> u.x*v.y - u.y*v.x

    lenS: (v) -> 
        Vec2.dot(v, v)

    len: => math.sqrt(self\lenS())

    unpack: => self.x, self.y
}
M.Vec2 = Vec2