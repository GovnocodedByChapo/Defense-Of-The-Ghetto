local Vector3D = require('vector3d')
local memory = require('memory')

--local core = require('DOTG1.core')
MODULE_MAP = {
    CURSOR_POINTER = nil,
    required_models = {
        103, 105, 107, 149, 269, 336, 339, 359
    },
    tower_model = 3286, 
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


    -->> LINES TREES
    --[[
    {
        comment = 'tree_groove_ez_1',
        model = 16061,
        pos = Vector3D(138, -19, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_2',
        model = 16061,
        pos = Vector3D(125, -27, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_3',
        model = 16061,
        pos = Vector3D(125, -83, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_4',
        model = 16061,
        pos = Vector3D(138, -69, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },

    {
        comment = 'tree_groove_ez_1',
        model = 16061,
        pos = Vector3D(175, -19, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_2',
        model = 16061,
        pos = Vector3D(175 - 10, -27, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_3',
        model = 16061,
        pos = Vector3D(175, -83, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    {
        comment = 'tree_groove_ez_4',
        model = 16061,
        pos = Vector3D(175, -69, 597),
        rotation = Vector3D(0, 0, 0),
        collision = true,
        scale = 0.5,
        dont_use_offset = true
    },
    ]]
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
local CREEP_SPAWNPOINT = {
    [SIDE_GROOVE] = {
        Vector3D(0, 0, 0),
        Vector3D(0, 0, 0),
        Vector3D(125 + 25, 0 - 125 - 25, 1)
    },
    [SIDE_BALLAS] = {
        Vector3D(10, 0, 0),
        Vector3D(10, 0, 0),
        Vector3D(10, 0, 0)
    }
}

MODULE_MAP.apply_hero_to_player = function()

end

MODULE_MAP.set_hp = function(ped, hp)
    assert(doesCharExist(ped), 'ped not found (incorrect handle)')
    local ptr = getCharPointer(ped)
    memory.setfloat(ptr + 0x540, hp, false)
    memory.setfloat(ptr + 0x544, hp, false)
end

MODULE_MAP.spawn_creep_stack = function(side, spawnpoint_index)
    local stack_size, stack_handles = 5, {}
    local spawn = CREEP_SPAWNPOINT[side][spawnpoint_index]
    for i = 1, stack_size do
        local new_bot = createChar(4, side == SIDE_GROOVE and 105 or 104, MODULE_MAP.pos.x + spawn.x, MODULE_MAP.pos.y + spawn.y, MODULE_MAP.pos.z + spawn.z)
        MODULE_MAP.set_hp(new_bot, 300)
        print('[DOTG1][DEBUG] map.lua -> spawn_creep_stack: ped created, handle:', new_bot, 'health:', getCharHealth(new_bot))
        giveWeaponToChar(new_bot, 8, 1)
        setCurrentCharWeapon(new_bot, 8)
        table.insert(stack_handles, new_bot)
        MODULE_MAP.pool.bots[new_bot] = 'creep_'..(side == SIDE_GROOVE and 'groove' or 'ballas')

        clearCharTasks(new_bot)
        taskWanderStandard(new_bot)
        lua_thread.create(function()
            while true do
                wait(0)
                if doesCharExist(new_bot) then
                    taskCharSlideToCoord(new_bot, 0, 0, MODULE_MAP.pos.z + 1, 0, 1)
                end
            end
        end)
    end
    return stack_size, stack_handles
end


MODULE_MAP.spawn_tower = function(pos, side)
    local tower_model = 3286--3279
    local new_object = createObject(MODULE_MAP.tower_model, pos.x, pos.y, pos.z - 4.5)
    setObjectCollision(new_object, true)
    setObjectScale(new_object, 0.7)
    table.insert(MODULE_MAP.pool.objects, new_object)
--
    --local tower_floor = createObject(19789, pos.x, pos.y, pos.z + 10.5)
    --setObjectScale(tower_floor, 0)
    --table.insert(MODULE_MAP.pool.objects, tower_floor)

    local new_bot = createChar(4, side == SIDE_GROOVE and 107 or 103, pos.x, pos.y, pos.z + 6)
    MODULE_MAP.set_hp(new_bot, 1000)
    giveWeaponToChar(new_bot, 35, 50)
    setCurrentCharWeapon(new_bot, 35)

    --attachCharToObject(new_bot, tower_floor, 0, 0, 2, 0, 0, 0)  -- 04F4
    setCharHeading(new_bot, 180)


    MODULE_MAP.pool.bots[new_bot] = 'tower_'..(side == 0 and 'groove' or 'ballas')
    return new_object, new_bot
end

MODULE_MAP.teleport_player_to_map = function()
    setCharCoordinates(PLAYER_PED, MODULE_MAP.pos.x, MODULE_MAP.pos.y, MODULE_MAP.pos.z)
end

local TEST_TOWER_BALLS = nil

MODULE_MAP.create_map = function()
    MODULE_MAP.CURSOR_POINTER = createObject(19605, MODULE_MAP.pos.x, MODULE_MAP.pos.y, MODULE_MAP.pos.z + 10) 
    --setObjectCollision(MODULE_MAP.CURSOR_POINTER, false)
    MODULE_MAP.spawn_tower(Vector3D(MODULE_MAP.pos.x + 125 + 27, MODULE_MAP.pos.y + 0, MODULE_MAP.pos.z), SIDE_GROOVE) -- groove down 1
    MODULE_MAP.spawn_tower(Vector3D(MODULE_MAP.pos.x + 125 + 27, MODULE_MAP.pos.y - 80, MODULE_MAP.pos.z), SIDE_GROOVE) -- groove down 2
    
    for index, data in ipairs(MODULE_MAP.items) do
        local opos = data.dont_use_offset == nil and Vector3D(MODULE_MAP.pos.x + data.pos.x, MODULE_MAP.pos.y + data.pos.y, MODULE_MAP.pos.z + data.pos.z) or Vector3D(data.pos.x, data.pos.y, data.pos.z) 
        local new_object = createObject(data.model, opos.x, opos.y, opos.z)
        setObjectRotation(new_object, data.rotation.x, data.rotation.y, data.rotation.z)
        setObjectScale(new_object, data.collision)
        setObjectScale(new_object, data.scale)

        table.insert(MODULE_MAP.pool.objects, new_object)
        --core.log('[MAP] create_map -> object'..(data.comment ~= nil and ' "'..data.comment..'"' or '')..' created. Model: '..data.model..', offsets: '..data.pos.x..';'..data.pos.y..';'..data.pos.z)
    end
end

MODULE_MAP.destroy_map = function()
    -->> Map objects
    for index, handle in ipairs(MODULE_MAP.pool.objects) do
        if doesObjectExist(handle) then
            deleteObject(handle)
            --core.log('[MAP] DESTROY -> object removed, handle: '..tostring(handle))
        end
    end
    if doesObjectExist(MODULE_MAP.CURSOR_POINTER) then
        deleteObject(MODULE_MAP.CURSOR_POINTER)
    end
    
    

    -->> Bots
    for handle, tag in pairs(MODULE_MAP.pool.bots) do
        if doesCharExist(handle) and handle ~= PLAYER_PED then
            deleteChar(handle)
           -- core.log('[MAP] DESTROY -> bot removed, handle: '..tostring(handle))
        end
    end
end

--[[
MODULE_MAP.spawn_bot = function(side)
    assert(core[side], 'map.lua -> spawn_bot(): incorrect side name, use core.SIDE.GROOVE (0) or core.SIDE.BALLAS (1)')
    local new_bot = createChar(4, math.random(MODULE_MAP.bot_models[side]), MODULE_MAP.pos.x + MODULE_MAP.bot_spawn_pos[side].x, MODULE_MAP.pos.y + MODULE_MAP.bot_spawn_pos[side].y, MODULE_MAP.pos.z + MODULE_MAP.bot_spawn_pos[side].z)
    --table.insert(MODULE_MAP.pool.bots, new_bot)
end
]]

MODULE_MAP.process_bot_behavior = function()

end


MODULE_MAP.draw_building_circles = function()
    for k, v in ipairs(MODULE_MAP.pool.objects) do
        if doesObjectExist(v) then
            if getObjectModel(v) == MODULE_MAP.tower_model then
                local result, x, y, z = getObjectCoordinates(v)
                if result then
                    MODULE_MAP.drawCircleIn3d(x, y, z, 10, 0xFFff0000, 3, 100)
                end
            end
        end
    end
end

local creep_movement = function(ped, move_points)
    
end

MODULE_MAP.bots_ai = function()
    for ped, tag in pairs(MODULE_MAP.pool.bots) do

        if tag:find('creep_(.+)') then
            local team = tag:match('creep_(.+)')
            taskCharSlideToCoord(ped, 0, 0, 0, 0, 1)
        end

        if tag:find('tower_(.+)') then
            local team = tag:match('tower_(.+)')
            -- find target for tower
            for target_ped, target_tag in pairs(MODULE_MAP.pool.bots) do
                local target_team = 'undefined'
                if target_tag:find('(.+)_(.+)') then
                    local target_type, target_team = target_tag:match('(.+)_(.+)')
                    if target_type == 'creep' or target_type == 'player' then
                        if team ~= target_team then
                            local pedX, pedY, pedZ = getCharCoordinates(target_ped)
                            local targetX, targetY, targetZ = getCharCoordinates(ped)
                            if getDistanceBetweenCoords3d(pedX, pedY, pedZ, targetX, targetY, targetZ) < 10 then
                                taskShootAtCoord(ped, targetX, targetY, targetZ, 2500)
                            end
                        end
                    end
                end
            end
        end
    end
end

MODULE_MAP.draw_circle_on_target = function()
    for handle, tag in pairs(MODULE_MAP.pool.bots) do
        local curX, curY = getCursorPos()
        local x, y, z = getCharCoordinates(handle)
        local pedX, pedY = convert3DCoordsToScreen(x, y, z)
        if getDistanceBetweenCoords2d(curX, curY, pedX, pedY) < 10 then
            --MODULE_MAP.drawCircleIn3d(x, y, z, 0.3, 0xFFff0000, 2, 100)
            drawShadow(3, x, y, z, 0.0, 1, 1, 1, 0, 0) 
        end
    end
end

MODULE_MAP.drawCircleIn3d = function(x, y, z, radius, color, width, polygons) 
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

MODULE_MAP.init = function()
    for k, v in ipairs(MODULE_MAP.required_models) do--MODULE_MAP.required_models) do
        if not hasModelLoaded(v) then
            requestModel(v)
            loadAllModelsNow()
        end
    end
end

MODULE_MAP.environment = [[]]

MODULE_MAP.create_environment = function()
    local items = MODULE_MAP.load_mta_map(MODULE_MAP.environment)
    for index, data in ipairs(items) do
        local opos = data.dont_use_offset == nil and Vector3D(MODULE_MAP.pos.x + data.pos.x, MODULE_MAP.pos.y + data.pos.y, MODULE_MAP.pos.z + data.pos.z) or Vector3D(data.pos.x, data.pos.y, data.pos.z) 
        local new_object = createObject(data.model, opos.x, opos.y, opos.z)
        setObjectRotation(new_object, data.rotation.x, data.rotation.y, data.rotation.z)
        setObjectScale(new_object, data.collision)
        setObjectScale(new_object, data.scale)

        table.insert(MODULE_MAP.pool.objects, new_object)
        --core.log('[MAP] create_map -> object'..(data.comment ~= nil and ' "'..data.comment..'"' or '')..' created. Model: '..data.model..', offsets: '..data.pos.x..';'..data.pos.y..';'..data.pos.z)
    end
end

MODULE_MAP.load_mta_map = function(code)
    local objects_list = {}

    for line in code:gmatch('[^\n]+') do
        if line:find('<object.+</object>') then
            local id = line:match('id="(.+)"%s')
            local model = line:match('model="(.+)"%s')
            local posX = line:match('posX="(.+)"%s')
            local posY = line:match('posY="(.+)"%s')
            local posZ = line:match('posZ="(.+)"%s')
            local rotX = line:match('rotX="(.+)"%s')
            local rotY = line:match('rotY="(.+)"%s')
            local rotZ = line:match('rotZ="(.+)"')
            table.insert(objects_list, {
                comment = id,
                model = tonumber(model),
                pos = Vector3D(tonumber(posX), tonumber(posY), tonumber(posZ)),
                rotation = Vector3D(tonumber(rotX), tonumber(rotY), tonumber(rotZ)),
                collision = true,
                scale = 1,
                dont_use_offset = true
            })
        end
    end

    return objects_list
end

return MODULE_MAP