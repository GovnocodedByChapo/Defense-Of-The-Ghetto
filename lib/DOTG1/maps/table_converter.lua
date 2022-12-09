local Vector3D = function(x, y, z) return {x, y, z} end
local TABLE = {}

local json = require('json') -- https://github.com/rxi/json.lua


local F = io.open(name or 'new_map.json', 'w')
F:write(json.encode(TABLE))
F:close()
print('Done! File:', 'new_map.json')