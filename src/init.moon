path = (...)\gsub(".init$", "") .. '.'

modules = {
    'class'
    'vectors'
    'luax'
    'cyclic'
    'matrices'
    'sets'
    'navigation'
}

for m in *modules do require(path .. m)
M = require(path .. 'master')
return {Navigation:M.Navigation}
