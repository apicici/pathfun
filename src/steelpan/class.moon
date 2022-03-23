excluded_keys = {
	'__init': true
	'__extends': true
	'__index': true
	'__class': true
}

Class = (tbl) ->
	assert(type(tbl) == 'table', "An initialisation table must be provided for the class")

	parent = tbl.__extends
	base = {k, v for k, v in pairs(parent and parent.__base or {}) when not excluded_keys[k] and tbl[k] == nil}

	c = {
		__parent: parent
		__base: base
		__index: tbl.__index or (parent and parent.__index)
		__init: tbl.__init or (parent and parent.__init) or =>
	}

	for k, v in pairs(tbl)
		base[k] = v if not excluded_keys[k]

	base.__class = c
	base.__index = if __index = c.__index
		(t, key) ->
			olditem = base[key]
			unless olditem == nil
				return olditem

			item = switch type(__index)
				when "table" then __index[key]
				when "function" then __index(t, key)
			return item
	else
		base

	setmetatable(c, {
		__call: (...) =>
			__newindex = base.__newindex
			base.__newindex = nil
			obj = setmetatable({}, base)
			self.__init(obj, ...)
			base.__newindex = __newindex
			return obj
			
		__index: base
	})

return Class