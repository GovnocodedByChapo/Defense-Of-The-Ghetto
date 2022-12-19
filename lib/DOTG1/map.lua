--[[
    map.lua:
        This file is a part of the DOTG1 mini-game.
        Author: chapo
        Last update: N/A
]] 

local Vector3D = require('vector3d')
local memory = require('memory')
local local_player = require('DOTG1.local_player')
local render_font = renderCreateFont('Trebuchet MS', 8, 5)
local DEBUG = false

SIDE_GROOVE, SIDE_BALLAS, MODULE_MAP = 0, 1, {
    CURSOR_POINTER = nil,
    required_models = {
        5, 103, 104, 105, 107, 149, 167, 269, 294, 336, 339, 358, 359
    },
    required_animations = {
        'UZI', 'BAT', 'grenade'
    },
    tower_model = 3286, 
    pos = Vector3D(0, 0, 600),
    items = {},
    pool = {
        towers = {},
        objects = {},
        bots = { [PLAYER_PED] = 'player_groove'},
        throns = {}
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

MODULE_MAP.spawn_throne = function(pos, gang)
    assert(gang, 'error spawning throne, missed arg #2 (gang index 0/1)')
    local o1 = createObject(6965, pos.x, pos.y, pos.z + 1)
    local o2 = createObject(9833, pos.x - 0.5, pos.y, pos.z + 9  )
    local o3 = createObject(348, pos.x - 1.5, pos.y, pos.z + 15)
    local o4 = createObject(348, pos.x + 1.5, pos.y, pos.z + 15)
    setObjectRotation(o3, 0, 270+45, 0)
    setObjectRotation(o4, 0, 270 + 45, 180)
    setObjectScale(o3, 15)
    setObjectScale(o4, 15)
    table.insert(MODULE_MAP.pool.objects, o1)
    table.insert(MODULE_MAP.pool.objects, o2)
    table.insert(MODULE_MAP.pool.objects, o3)
    table.insert(MODULE_MAP.pool.objects, o4)
    table.insert(MODULE_MAP.pool.throns, {
        base = o1,
        w1 = o2,
        w2 = o3,
        dick = o4
    })
end

MODULE_MAP.deal_damage_to_point = function(point, radius, damage, team_damage)
    for ped, tag in pairs(MODULE_MAP.pool.bots) do
        if doesCharExist(ped) then
            if team_damage or not tag:find('groove') then
                local ped_pos = Vector3D(getCharCoordinates(ped))
                if getDistanceBetweenCoords3d(point.x, point.y, point.z, ped_pos.x, ped_pos.y, ped_pos.z) <= radius then
                    local start_hp = getCharHealth(ped)
                    if start_hp - damage <= 0 then
                        MODULE_MAP.pool.bots[ped] = nil
                        deleteChar(ped)
                    else
                        MODULE_MAP.set_hp(ped, start_hp - damage)
                    end
                end
            end
        end
    end
end

MODULE_MAP.spawn_background = function()
    for i = 1, 8 do
        local no = createObject(17031, MODULE_MAP.pos.x - 227, MODULE_MAP.pos.y - 200 + 50 * i, MODULE_MAP.pos.z - 1)
        setObjectScale(no, 1.5)
        table.insert(MODULE_MAP.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, MODULE_MAP.pos.x + 227, MODULE_MAP.pos.y - 200 + 50 * i, MODULE_MAP.pos.z - 1)
        setObjectHeading(no, 180)
        setObjectScale(no, 1.5)
        table.insert(MODULE_MAP.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, MODULE_MAP.pos.x - 200 + 50 * i, MODULE_MAP.pos.y - 227, MODULE_MAP.pos.z - 1)
        setObjectHeading(no, 90)
        setObjectScale(no, 1.5)
        table.insert(MODULE_MAP.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, MODULE_MAP.pos.x - 200 + 50 * i, MODULE_MAP.pos.y + 227, MODULE_MAP.pos.z - 1)
        setObjectHeading(no, 270)
        setObjectScale(no, 1.5)
        table.insert(MODULE_MAP.pool.objects, no)
    end
end

MODULE_MAP.set_hp = function(ped, hp)
    assert(doesCharExist(ped), 'ped not found (incorrect handle)')
    local ptr = getCharPointer(ped)
    memory.setfloat(ptr + 0x540, hp, false)
    memory.setfloat(ptr + 0x544, hp, false)
end

MODULE_MAP.spawn_tower = function(pos, gang)
    local new_object = createObject(MODULE_MAP.tower_model, pos.x, pos.y, pos.z - 4.5)
    local new_ped = createChar(4, gang == SIDE_GROOVE and 105 or 104, pos.x, pos.y, pos.z)-- + 6)
    MODULE_MAP.set_hp(new_ped, 1000)
    table.insert(MODULE_MAP.pool.towers, {
        gang = gang,
        ped = new_ped,
        object = new_object,
        health = 1000
    })
    table.insert(MODULE_MAP.pool.objects, new_object)
    MODULE_MAP.pool.bots[new_ped] = 'tower_'..(gang == 0 and 'groove' or 'ballas')
    return new_object, new_bot
end

MODULE_MAP.teleport_player_to_map = function()
    setCharCoordinates(PLAYER_PED, MODULE_MAP.pos.x, MODULE_MAP.pos.y, MODULE_MAP.pos.z)
end

MODULE_MAP.create_map = function()
    MODULE_MAP.CURSOR_POINTER = createObject(19605, MODULE_MAP.pos.x, MODULE_MAP.pos.y, MODULE_MAP.pos.z + 10) 
    --setObjectVisible(MODULE_MAP.CURSOR_POINTER, false)
    --setObjectScale(MODULE_MAP.CURSOR_POINTER, 0)
    --setObjectCollision(MODULE_MAP.CURSOR_POINTER, false)
    MODULE_MAP.spawn_tower(Vector3D(MODULE_MAP.pos.x + 125 + 27, MODULE_MAP.pos.y + 0, MODULE_MAP.pos.z), SIDE_GROOVE) -- groove down 1
    MODULE_MAP.spawn_tower(Vector3D(MODULE_MAP.pos.x + 125 + 27, MODULE_MAP.pos.y - 80, MODULE_MAP.pos.z), SIDE_GROOVE) -- groove down 2
    MODULE_MAP.spawn_background()
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

MODULE_MAP.bots_ai = function()
    --[[
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
    ]]
end

MODULE_MAP.draw_circle_on_target = function()
    for handle, tag in pairs(MODULE_MAP.pool.bots) do
        if doesCharExist(handle) then
            local curX, curY = getCursorPos()
            local x, y, z = getCharCoordinates(handle)
            local pedX, pedY = convert3DCoordsToScreen(x, y, z)
            if getDistanceBetweenCoords2d(curX, curY, pedX, pedY) < 10 then
                --MODULE_MAP.drawCircleIn3d(x, y, z, 0.3, 0xFFff0000, 2, 100)
                drawShadow(3, x, y, z, 0.0, 1, 1, 1, 0, 0) 
            end
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
    local_player.PLAYER.selected_map = MODULE_MAP.get_maps_list()[1]
    for k, v in ipairs(MODULE_MAP.required_models) do--MODULE_MAP.required_models) do
        if not hasModelLoaded(v) then
            requestModel(v)
            loadAllModelsNow()
        end
    end
    --[[
    for k, v in ipairs(MODULE_MAP.required_animations) do
        if not hasAnimationLoaded(v) then
            requestAnimation(v)
        end
    end
    ]]
end

MODULE_MAP.get_distance_from_pointer = function(x, y, z)
    if doesObjectExist(MODULE_MAP.CURSOR_POINTER) then
        local result, px, py, pz = getObjectCoordinates(MODULE_MAP.CURSOR_POINTER)
        if result then
            return getDistanceBetweenCoords3d( px, py, pz, x, y, z )
        end
    end
    return -1
end

local getFilesInPath = function(path, ftype)
    local Files, SearchHandle, File = {}, findFirstFile(path.."\\"..ftype)
    table.insert(Files, File)
    while File do File = findNextFile(SearchHandle) table.insert(Files, File) end
    return Files
end

MODULE_MAP.get_maps_list = function()
    assert(doesDirectoryExist(getWorkingDirectory()..'\\lib\\DOTG1\\maps'), 'maps path not found!')
    return getFilesInPath(getWorkingDirectory()..'\\lib\\DOTG1\\maps', '*.json')
end

MODULE_MAP.load_ai_for_creep = function(ai_loop_start, handle, team, route_end, route_center, final_taget)
    lua_thread.create(function()
        assert(route_center, 'no route_center')
        local center_point_passed, route_passed = route_center == nil, false
        while true do
            wait(0)
            if doesCharExist(handle) then
                local render_text = 'CREEP_'..tostring(handle)
                local target_tower_find = false
                local go_to_pos = center_point_passed and route_end or route_center
                
                local ped = Vector3D(getCharCoordinates(handle))
                local ped_screen_x, ped_screen_y = convert3DCoordsToScreen(ped.x, ped.y, ped.z)
                for index, tower in ipairs(MODULE_MAP.pool.towers) do
                    if doesObjectExist(tower.object) and doesCharExist(tower.ped) then
                        if getCharModel(handle) ~= getCharModel(tower.ped) then
                            local result, x, y, z = getObjectCoordinates(tower.object)
                            if result then
                                if getDistanceBetweenCoords3d(x, y, z, ped.x, ped.y, ped.z) <= 7 then
                                    target_tower_find = true
                                    taskCharSlideToCoord(handle, x, y, z, 0, 1)
                                    MODULE_MAP.set_hp(tower.ped, getCharHealth(tower.ped) - 5)
                                    if getCharHealth(tower.ped) <= 0 then
                                        deleteObject(tower.object)
                                    end
                                    wait(1000)
                                end
                            end
                        end
                    end
                end
                
                if not target_tower_find then
                    taskCharSlideToCoord(handle, go_to_pos.x, go_to_pos.y, go_to_pos.z, 0, 1)
                    if getDistanceBetweenCoords3d(go_to_pos.x, go_to_pos.y, go_to_pos.z, ped.x, ped.y, ped.z) <= 2 then
                        if center_point_passed then
                            if not route_passed then
                                route_passed = true
                            end
                        else
                            center_point_passed = true
                        end
                    end
                end
                if DEBUG then
                    if render_font == nil then
                        _G.render_font = renderCreateFont('Trebuchet MS', 8, 5)
                    end
                    local render_text = ('creep=%d;\ntarget_tower_find=%s;\ncenter_point_passed=%s'):format(
                        handle, tostring(target_tower_find), tostring(center_point_passed)
                    )
                    renderFontDrawText(render_font, render_text, ped_screen_x, ped_screen_y , 0xFFffffff)
                end
            else
                return print('[MAP][AI] Creep brains disabled, creep not found. Team: '..team)
            end
            wait(5000)
        end
    end)
end

MODULE_MAP.load_map = function(file, team, teleport_on_spawn)
    assert(doesFileExist(getWorkingDirectory()..'\\lib\\DOTG1\\maps\\'..file), 'map "'..file..'" not found!')
    local F = io.open(getWorkingDirectory()..'\\lib\\DOTG1\\maps\\'..file, 'r')
    local JSON = F:read('*all')
    F:close()
    assert(#JSON > 0, 'JSON (map data) is empty!')

    -->> POINTER
    if MODULE_MAP.CURSOR_POINTER and doesObjectExist(MODULE_MAP.CURSOR_POINTER) then
        deleteObject(MODULE_MAP.CURSOR_POINTER)
    end
    MODULE_MAP.CURSOR_POINTER = createObject(19605, 0, 0, 0) 
    setObjectVisible(MODULE_MAP.CURSOR_POINTER, true)

    local data = decodeJson(JSON)
    local team = team or 0

    -->> spawn rock bg
    if data.spawn_rock_background then
        MODULE_MAP.spawn_background()
    end
    
    -->> spawn objects
    for index, data in ipairs(data.objects) do
        --local opos = Vector3D(MODULE_MAP.pos.x + data.pos[1], MODULE_MAP.pos.y + data.pos[2], MODULE_MAP.pos.z + data.pos[3])
        local opos = Vector3D(data.pos[1], data.pos[2], data.pos[3])
        
        local new_object = createObject(data.model, opos.x, opos.y, opos.z)
        setObjectRotation(new_object, data.rotation[1], data.rotation[2], data.rotation[3])
        setObjectScale(new_object, data.collision or true)
        setObjectScale(new_object, data.scale or 1)
        table.insert(MODULE_MAP.pool.objects, new_object)
    end

    -->> spawn towers
    for team, items in pairs(data.towers) do
        for index, pos_table in pairs(items) do
            MODULE_MAP.spawn_tower(Vector3D(table.unpack(pos_table)), team - 1)
            print('TOWER_SPAWNED:', team + 1, index, table.unpack(pos_table))
        end
    end

    -->> teleport
    setCharCoordinates(PLAYER_PED, table.unpack(data.spawn_point[team + 1]))

    -->> creeps ai
    --
    for route_index, creep_routes in pairs(data.creeps_routes) do
        local creep_team = creep_routes.team
        for i = 1, tonumber(creep_routes.creeps_count) do
            local route_start = Vector3D(creep_routes.spawn[1], creep_routes.spawn[2], creep_routes.spawn[3])
            local new_creep = createChar(4, creep_team == SIDE_GROOVE and 105 or 104, route_start.x - i / 6, route_start.y, route_start.z)
            MODULE_MAP.pool.bots[new_creep] = 'creep_'..(creep_team == SIDE_GROOVE and 'groove' or 'ballas')..'_'..encodeJson(creep_routes.stop)
            MODULE_MAP.set_hp(new_creep, 300)
            MODULE_MAP.load_ai_for_creep(
                os.clock(), 
                new_creep, 
                creep_team, 
                Vector3D(creep_routes.stop[1], creep_routes.stop[2], creep_routes.stop[3]), 
                Vector3D(creep_routes.center[1], creep_routes.center[2], creep_routes.center[3])
            )-- NASRAL POTOKAMI!!!!
        end
    end
    
    -->> thrones
    --[[
    for throne_index, throne_data in ipairs(data.thrones) do
        MODULE_MAP.spawn_throne(Vector3D(throne_data.pos[1], throne_data.pos[2], throne_data.pos[3]), throne_data.team)
    end
    ]]
end

return MODULE_MAP