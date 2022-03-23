path = (...)\gsub("[^%.]*$", "")
Class = require path .. 'class'

__next = (t, key) -> -- used for set iterator
    k = next(t, key)
    return k

local Set
Set = Class {
    __init: (t) =>
        n, items = 0, {}

        if type(t) == "table"
            for value in *t
                n +=1
                items[value] = true

        @n = n
        @items = items

    add: (value) =>
        unless @items[value]
            @n += 1
            @items[value] = true
    
    remove: (value) =>
        if @items[value]
            @n -= 1
            @items[value] = nil

    size: => @n

    iterator: =>
        __next, @items, nil

    contains: (value) =>
        @items[value] or false

    union: (s1, s2) ->
        union = Set()
        union\add(v) for v in pairs(s1)
        union\add(v) for v in pairs(s2)
        return union

    intersection: (s1, s2) ->
        intersection = Set()
        for v in pairs(s1)
            intersection\add(v) if s2.items[v]

    totable: => [k for k in pairs(self.items)]
}

Set.range = (n) ->
    t = [i for i=1, n]
    Set(t)

return Set
