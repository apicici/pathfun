path = (...)\gsub(".init$", "") .. '.'

M = require(path .. 'main')

steelpan = {
    "class": "Class"
    "vectors": "Vec2"
    "geometry": "geometry"
    "cyclic": "CyclicList"
    "sets": "Set"
    "matrices": "matrices"
    "utils": "utils"
}

M.steelpan = {k, require(path .. "steelpan." .. m) for m, k in pairs(steelpan)}

require path .. "navigation"
return {Navigation:M.Navigation}