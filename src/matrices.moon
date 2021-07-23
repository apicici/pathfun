path = (...)\gsub("[^%.]*$", "")
M = require(path .. 'master')

local *

Matrix = M.class {
    __init: (@num_rows, @num_cols, @default_value) =>
        self.matrix = {}

    __index: (m, row) ->
        if type(row) == 'number'
            assert(row >= 1 and row <= m.num_rows, "indices out of range")
            setmetatable({parent:m, row:row}, row_mt)
}
M.Matrix = Matrix

M.SymmetricMatrix = M.class {
    __extends: Matrix
    __init: (num_rows, default_value) =>
        self.symmetric = true
        Matrix.__init(self, num_rows, num_rows, default_value)
}

row_mt = {
    __index: (r, col) ->
        parent = r.parent
        num_cols = parent.num_cols
        symmetric = parent.symmetric
        row = r.row
        assert(col >= 1 and col <= num_cols, "indices out of range")

        idx = if symmetric and col < row
            col*num_cols + row
        else
            row*num_cols + col

        return parent.matrix[idx] or parent.default_value

    __newindex: (r, col, value) ->
        parent = r.parent
        num_cols = parent.num_cols
        symmetric = parent.symmetric
        row = r.row
        assert(col >= 1 and col <= num_cols, "indices out of range")

        idx = if symmetric and col < row
            col*num_cols + row
        else
            row*num_cols + col

        parent.matrix[idx] = value
}

