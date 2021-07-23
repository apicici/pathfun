path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

__next = (t, key) -> -- used for set iterator
    k, _ = next(t, key)
    return k

Set = M.class {
    __init: (t={}) =>
        n, items = 0, {}
        for value in *t
            n +=1
            items[value] = true

        self.n = n
        self.items = items

    add: (value) =>
        unless self\contains(value)
            self.n += 1
            self.items[value] = true
    
    remove: (value) =>
        if self\contains(value)
            self.n = self.n - 1
            self.items[value] = nil

    size: => self.n

    iterator: =>
        __next, self.items, nil

    contains: (element) =>
        self.items[element] or false
}
M.Set = Set