path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

M.CyclicList = M.class {
    __init: (t) =>
        self.n = #t
        self.items = t

	__index: (key) =>
		type(key) == 'number' and self.items[((key - 1) % self.n) + 1]
}
