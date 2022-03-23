path = (...)\gsub("[^%.]*$", "")
Class = require path .. 'class'

CyclicList = Class {
    __init: (t) =>
        @n = #t
        @items = t

	__index: (key) =>
		@items[((key - 1) % @n) + 1]

	insert: (i, x) =>
		@n += 1	
		if x == nil
			x = i
			i = @n
		else
			i = ((i - 1) % @n) + 1
		table.insert(@items, i, x)

	remove: (i) =>
		return if @n == 0	
		i = i and ((i - 1) % @n) + 1 or @n
		@n -= 1
		table.remove(self.items, i)

    len: => @n

    ipairs: => ipairs(@items)

    totable: => @items
}

return CyclicList