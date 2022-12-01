local Vector3D = require('vector3d')
local core = require('DOTG1.core')
MODULE = {
    pos = Vector3D(0, 0, 100),
    items = {
        {
            comment = 'comment',
            model = 19999,
            pos = Vector3D(0, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        }
    },
    pool = {
        objects = {},
        bots = {}
    },
    bot_models = {
        [core.SIDE.GROOVE] = {},
        [core.SIDE.BALLAS] = {}
    },
    bot_spawn_pos = {
        [core.SIDE.GROOVE] = Vector3D(0, 0, 0),
        [core.SIDE.BALLAS] = Vector3D(1, 1, 1)
    }
}

MODULE.create_map = function()
    for index, data in ipairs(MODULE.items) do
        local new_object = createObject(data.model, MODULE.pos.x + data.pos.x, MODULE.pos.y + data.pos.y, MODULE.pos.z + data.pos.z)
        setObjectRotation(new_object, data.rotation.x, data.rotation.y, data.rotation.z)
        setObjectScale(new_object, data.collision)
        setObjectScale(new_object, data.scale)

        table.insert(MODULE.pool.objects, new_object)
        core.log('[MAP] create_map -> object'..(data.comment ~= nil and ' "'..data.comment..'"' or '')..' created. Model: '..data.model..', offsets: '..data.pos.x..';'..data.pos.y..';'..data.pos.z)
    end
end

MODULE.destroy_map = function()
    for index, handle in ipairs(MODULE.pool.objects) do
        if doesObjectExist(handle) then
            deleteObject(handle)
            core.log('[MAP] DESTROY -> object removed, handle: '..tostring(handle))
        end
    end
end

MODULE.spawn_bot = function(side)
    assert(core[side], 'map.lua -> spawn_bot(): incorrect side name, use core.SIDE.GROOVE (0) or core.SIDE.BALLAS (1)')
    local new_bot = createChar(4, math.random(MODULE.bot_models[side]), MODULE.pos.x + MODULE.bot_spawn_pos[side].x, MODULE.pos.y + MODULE.bot_spawn_pos[side].y, MODULE.pos.z + MODULE.bot_spawn_pos[side].z)
    table.insert(MODULE.pool.bots, new_bot)
end

MODULE.process_bot_behavior = function()
    
end

return MODULE