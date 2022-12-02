local Vector3D = require('vector3d')
--local core = require('DOTG1.core')
MODULE = {
    required_models = {
        105, 103, 359
    },
    pos = Vector3D(0, 0, 600),
    items = {
        {
            comment = 'comment',
            model = 19999,
            pos = Vector3D(0, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        --[[
        {
            comment = 'floor_center',
            model = 18754,
            pos = Vector3D(0, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        ]]

        {
            comment = 'floor_1',
            model = 19551,
            pos = Vector3D(-125, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        {
            comment = 'floor_2_center',
            model = 19550,
            pos = Vector3D(0, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        {
            comment = 'floor_3',
            model = 19550,
            pos = Vector3D(125, 0, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        ------
        {
            comment = 'floor_4',
            model = 19551,
            pos = Vector3D(-125, 125, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        {
            comment = 'floor_5',
            model = 19551,
            pos = Vector3D(0, 125, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
        {
            comment = 'floor_6',
            model = 19550,
            pos = Vector3D(125, 125, 0),
            rotation = Vector3D(0, 0, 0),
            collision = true,
            scale = 1
        },
       ------
       {
        comment = 'floor_4',
        model = 19550,
        pos = Vector3D(-125, -125, 0),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 1
    },
    {
        comment = 'floor_5',
        model = 19550,
        pos = Vector3D(0, -125, 0),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 1
    },
    {
        comment = 'floor_6',
        model = 19550,
        pos = Vector3D(125, -125, 0),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 1
    },
        
        
    },
    pool = {
        objects = {},
        bots = {
            [PLAYER_PED] = 'player_groove'
        }
    },
    bot_models = {
        [0] = {},
        [1] = {}
    },
    bot_spawn_pos = {
        [0] = Vector3D(0, 0, 0),
        [1] = Vector3D(1, 1, 1)
    }
}



SIDE_GROOVE, SIDE_BALLAS = 0, 1
MODULE.spawn_tower = function(pos, side)
    local tower_model = 3279
    local new_object = createObject(tower_model, pos.x, pos.y, pos.z)
    setObjectCollision(new_object, false)
    setObjectScale(new_object, 0.7)
    table.insert(MODULE.pool.objects, new_object)

    local tower_floor = createObject(19789, pos.x, pos.y, pos.z + 10.5)
    setObjectScale(tower_floor, 0)
    table.insert(MODULE.pool.objects, tower_floor)

    local new_bot = createChar(4, side == SIDE_GROOVE and 107 or 103, pos.x, pos.y, pos.z + 13)
    giveWeaponToChar(new_bot, 35, 50)
    setCurrentCharWeapon(new_bot, 35)

    MODULE.pool.bots[new_bot] = 'tower_'..(side == 0 and 'groove' or 'ballas')
    return new_object, new_bot
end

MODULE.teleport_player_to_map = function()
    setCharCoordinates(PLAYER_PED, MODULE.pos.x, MODULE.pos.y, MODULE.pos.z)
end

local TEST_TOWER_BALLS = nil

MODULE.create_map = function()
    --MODULE.spawn_tower(Vector3D(0, 0, MODULE.pos.z), SIDE_GROOVE)
    _, TEST_TOWER_BALLS = MODULE.spawn_tower(Vector3D(5, 0, MODULE.pos.z), SIDE_BALLAS)
    for index, data in ipairs(MODULE.items) do
        local new_object = createObject(data.model, MODULE.pos.x + data.pos.x, MODULE.pos.y + data.pos.y, MODULE.pos.z + data.pos.z)
        setObjectRotation(new_object, data.rotation.x, data.rotation.y, data.rotation.z)
        setObjectScale(new_object, data.collision)
        setObjectScale(new_object, data.scale)

        table.insert(MODULE.pool.objects, new_object)
        --core.log('[MAP] create_map -> object'..(data.comment ~= nil and ' "'..data.comment..'"' or '')..' created. Model: '..data.model..', offsets: '..data.pos.x..';'..data.pos.y..';'..data.pos.z)
    end
end

MODULE.destroy_map = function()
    -->> Map objects
    for index, handle in ipairs(MODULE.pool.objects) do
        if doesObjectExist(handle) then
            deleteObject(handle)
            --core.log('[MAP] DESTROY -> object removed, handle: '..tostring(handle))
        end
    end

    -->> Bots
    for handle, tag in pairs(MODULE.pool.bots) do
        if doesCharExist(handle) and handle ~= PLAYER_PED then
            deleteChar(handle)
           -- core.log('[MAP] DESTROY -> bot removed, handle: '..tostring(handle))
        end
    end
end

--[[
MODULE.spawn_bot = function(side)
    assert(core[side], 'map.lua -> spawn_bot(): incorrect side name, use core.SIDE.GROOVE (0) or core.SIDE.BALLAS (1)')
    local new_bot = createChar(4, math.random(MODULE.bot_models[side]), MODULE.pos.x + MODULE.bot_spawn_pos[side].x, MODULE.pos.y + MODULE.bot_spawn_pos[side].y, MODULE.pos.z + MODULE.bot_spawn_pos[side].z)
    --table.insert(MODULE.pool.bots, new_bot)
end
]]

MODULE.process_bot_behavior = function()

end


MODULE.draw_building_circles = function()
    for k, v in ipairs(MODULE.pool.objects) do
        if doesObjectExist(v) then
            if getObjectModel(v) == 3279 then
                local result, x, y, z = getObjectCoordinates(v)
                if result then
                    MODULE.drawCircleIn3d(x, y, z, 10, 0xFFff0000, 3, 100)
                end
            end
        end
    end
end

MODULE.bots_ai = function()
    if doesCharExist(TEST_TOWER_BALLS) then
        taskShootAtCoord(TEST_TOWER_BALLS, getCharCoordinates(PLAYER_PED), 1000)
    else
        print('TEST_TOWER_BALLS does not exists')
    end
    for ped, tag in pairs(MODULE.pool.bots) do
        if tag:find('tower_(.+)') then
            local team = tag:match('tower_(.+)')
            -- find target for tower
            for target_ped, target_tag in pairs(MODULE.pool.bots) do
            --    local target_team = 'undefined'
            --    if target_tag:find('(.+)_(.+)') then
            --        local target_type, target_team = target_tag:match('(.+)_(.+)')
            --        if target_type == 'creep' or target_type == 'player' then
            --            if team ~= target_team then
            --                local pedX, pedY, pedZ = getCharCoordinates(target_ped)
            --                local targetX, targetY, targetZ = getCharCoordinates(ped)
            --                if getDistanceBetweenCoords3d(pedX, pedY, pedZ, targetX, targetY, targetZ) < 10 then
            --                    taskShootAtCoord(ped, targetX, targetY, targetZ, 2500)
            --                end
            --            end
            --        end
            --    end
            end
        end
    end
end

MODULE.drawCircleIn3d = function(x, y, z, radius, color, width, polygons) 
    local step = math.floor(360 / (polygons or 36)) 
    local sX_old, sY_old 
    for angle = 0, 360, step do  
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(radius * math.cos(math.rad(angle)) + x , radius * math.sin(math.rad(angle)) + y , z) 
        if sZ > 1 then 
            if sX_old and sY_old then 
                renderDrawLine(sX, sY, sX_old, sY_old, width, color) 
            end 
            sX_old, sY_old = sX, sY 
        end 
    end 
end

MODULE.init = function()
    for k, v in ipairs(MODULE.required_models) do
        if not hasModelLoaded(v) then
            requestModel(v)
            loadAllModelsNow()
        end
    end
end

return MODULE