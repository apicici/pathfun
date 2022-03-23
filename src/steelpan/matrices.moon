path = (...)\gsub("[^%.]*$", "")
Class = require path .. 'class'

Matrix = Class {
    __init: (@num_rows, @num_cols, @default_value) =>
        @matrix = {}

    get: (i, j) =>
        assert(i >= 1 and i <= @num_rows and j >= 1 and j <= @num_cols, "indices out of range")
        idx = i*@num_cols + j
        return @matrix[idx] or @default_value

    set: (i, j, value) => 
        assert(i >= 1 and i <= @num_rows and j >= 1 and j <= @num_cols, "indices out of range")
        idx = i*@num_cols + j
        @matrix[idx] = value
}

SymmetricMatrix = Class {
    __init: (num_rows, default_value) =>
        Matrix.__init(self, num_rows, num_rows, default_value)

    get: (i, j) =>
        j, i = i, j if j < i
        Matrix.get(self, i, j)

    set: (i, j, value) =>
        j, i = i, j if j < i
        Matrix.set(self, i, j, value)
}

return {:Matrix, :SymmetricMatrix}
