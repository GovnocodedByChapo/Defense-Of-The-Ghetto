--[[
    movement.lua:
        This file is a part of the DOTG1 mini-game.
        Author: chapo
        Last update: N/A
]] 
require('lib.moonloader')
local Vector3D = require('vector3d')
local map = require('DOTG1.map')
local local_player = require('DOTG1.local_player')
--local items = require('DOTG1.items')
GAME_STATE = { NONE = 0, MAIN_MENU = 1, HERO_SELECT = 2, IN_GAME = 3 }
MOVEMENT = {
    go_to_coords = false,
    go_to_coords_coords = Vector3D(0, 0, 0),
    circles = {},
    target_handle = 1,
    last_hit = 0
}

MOVEMENT.setup_key_hook = function()
    
end

MOVEMENT.get_pointer_pos = function(custom)
    local args = custom or {true, true, false, true, false, false, false}
    local curX, curY = getCursorPos()
    local resX, resY = getScreenResolution()
    local posX, posY, posZ = convertScreenCoordsToWorld3D(curX, curY, 700.0)
    local camX, camY, camZ = getActiveCameraCoordinates()
    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, table.unpack(args))
    if result and colpoint.entity ~= 0 then
        local normal = colpoint.normal
        local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
        local zOffset = 300
        if normal[3] >= 0.5 then zOffset = 1 end
        local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3, table.unpack(args))
        if result then
            return Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3]), colpoint2
        end
    end
    return Vector3D(0, 0, 0), colpoint
end

MOVEMENT.loop = function()
    local pos = MOVEMENT.get_pointer_pos(nil)
    if wasKeyPressed(VK_RBUTTON) then
        local beat_target = false
        if doesObjectExist(map.CURSOR_POINTER) then
            local cursor_result, cursorX, cursorY, cursorZ = getObjectCoordinates(map.CURSOR_POINTER)
            for handle, tag in pairs(map.pool.bots) do
                if handle ~= PLAYER_PED then
                    local x, y, z = getCharCoordinates(handle)
                    if getDistanceBetweenCoords3d(cursorX, cursorY, cursorZ, x, y, z) < 1 then
                        MOVEMENT.target_handle = handle
                        beat_target = true
                        sampAddChatMessage('gotoped', -1)
                        break
                    end
                end
            end
        end
        if not beat_target then
            MOVEMENT.target_handle = nil
        end
        
        MOVEMENT.go_to_coords = true
        MOVEMENT.go_to_coords_coords = pos
        table.insert(MOVEMENT.circles, {
            pos = pos,
            start = os.clock(),
            radius = 0.5,
            alpha = 255
        })
    end

    -->> GO TO COORDS
    if MOVEMENT.go_to_coords then
        local ped = Vector3D(getCharCoordinates(PLAYER_PED))
        local go_to = Vector3D(MOVEMENT.go_to_coords_coords.x,  MOVEMENT.go_to_coords_coords.y,  MOVEMENT.go_to_coords_coords.z)
        
        if MOVEMENT.target_handle and MOVEMENT.target_handle ~= PLAYER_PED then
            if doesCharExist(MOVEMENT.target_handle) then
                go_to = Vector3D(getCharCoordinates(MOVEMENT.target_handle))
            else
                MOVEMENT.target_handle = nil
            end
        end
        --print(PLAYER_PED, go_to.x, go_to.y, go_to.z, getCharHeading(PLAYER_PED), 1)
        taskCharSlideToCoord(PLAYER_PED, go_to.x, go_to.y, go_to.z, getCharHeading(PLAYER_PED), 1)
        --taskCharSlideToCoordAndPlayAnim(PLAYER_PED, go_to.x, go_to.y, go_to.z, 0, 1, PLAYER.hero.hit_animation.name, PLAYER.hero.hit_animation.file, 100, false, false, false, false, false)
                
        setGameKeyState(16, 256)
        if getDistanceBetweenCoords3d(ped.x, ped.y, ped.z, go_to.x,  go_to.y,  go_to.z) <= 1.5 then
            if MOVEMENT.target_handle then
            --    local target = Vector3D(getCharCoordinates(MOVEMENT.target_handle))
            --    local player = Vector3D(getCharCoordinates(PLAYER_PED))
            --    if getDistanceBetweenCoords3d(target.x, target.y, target.z, player.x, player.y, player.z) > 1 then
            --       -- taskCharSlideToCoord(PLAYER_PED, target.x, target.y, target.z, getCharHeading(PLAYER_PED), 1)
            --    else
            --        --clearCharTasksImmediately(PLAYER_PED)     
            --    end
                   
            else
                MOVEMENT.go_to_coords = false
            end

        end
    end
end

MOVEMENT.fight_loop = function()
    if MOVEMENT.target_handle and MOVEMENT.target_handle ~= PLAYER_PED then
        if doesCharExist(MOVEMENT.target_handle) then
            local target = Vector3D(getCharCoordinates(MOVEMENT.target_handle))
            local player = Vector3D(getCharCoordinates(PLAYER_PED))
            if getDistanceBetweenCoords3d(target.x, target.y, target.z, player.x, player.y, player.z) <= local_player.PLAYER.hero.hit_distance then
                local fire_rate = 1
                if MOVEMENT.last_hit + local_player.PLAYER.hero.hit_speed - os.clock() <= 0 then
                    MOVEMENT.last_hit = os.clock()
                    clearCharTasksImmediately(PLAYER_PED)
                    taskPlayAnim(PLAYER_PED, local_player.PLAYER.hero.hit_animation.name, local_player.PLAYER.hero.hit_animation.file, 1000, false, false, false, false, -1)
                    map.set_hp(MOVEMENT.target_handle, getCharHealth(MOVEMENT.target_handle) - local_player.PLAYER.hero.damage) -- 20 - damage
                    if getCharHealth(MOVEMENT.target_handle) <= 0 then
                        map.pool.bots[MOVEMENT.target_handle] = nil
                        deleteChar(MOVEMENT.target_handle)
                        MOVEMENT.target_handle = nil
                        MOVEMENT.go_to_coords = false
                        clearCharTasksImmediately(PLAYER_PED)
                        math.randomseed(os.clock() * math.random(1, 9999))
                        local reward = math.random(40, 100)
                        local_player.money = local_player.money + reward
                        printStringNow('~y~+ '..reward, 500)
                    end
                end
            end
            local sx, sy = convert3DCoordsToScreen(target.x, target.y, target.z)
            renderDrawPolygon(sx, sy, 20, 20, 10, 0, 0xFFff0000)
        end
    end
end

MOVEMENT.draw_circles = function()
    for index, data in ipairs(MOVEMENT.circles) do
        if data.radius < 1 then
            map.drawCircleIn3d(data.pos.x, data.pos.y, data.pos.z, data.radius, join_argb(data.alpha, 0, 255, 0), 2, 100) 
            local sx, sy = convert3DCoordsToScreen(data.pos.x, data.pos.y, data.pos.z)
            local sy = sy - 15 + data.radius * 10
            renderDrawBox(sx - 2, sy - 10, 4, 10, join_argb(data.alpha, 0, 255, 0))
            renderDrawPolygon(sx, sy, 10, 10, 3, 180, join_argb(data.alpha, 0, 255, 0))
            MOVEMENT.circles[index].radius = bringFloatTo(data.radius, 1, data.start, 0.7)
            MOVEMENT.circles[index].alpha = bringFloatTo(data.alpha, 0, data.start, 0.7)
        end
    end
end

MOVEMENT.disable_game_keys = function()
    for i = 0, 20 do
        if i ~= 16 and isButtonPressed(Player, i) then
            setGameKeyState(i, 0)
        end
    end
end

return MOVEMENT