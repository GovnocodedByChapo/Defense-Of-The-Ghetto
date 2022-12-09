local TABLE = {}

print('Enter map name:')
local name = io.read("*a")
local F = io.open(name or 'new_map.json', 'w')
F:write(json.encode(TABLE))
F:close()
print('Done! File:', name or 'new_map.json')