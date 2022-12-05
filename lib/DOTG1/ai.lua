local map = require('DOTG1.map')
local local_player = require('DOTG1.local_player')
SIDE_GROOVE, SIDE_BALLAS = 0, 1
CREEP_ROUTE = {
    [SIDE_GROOVE] = {},
    [SIDE_BALLAS] = {}
}
AI = {}

AI.tower_loop = function()
    lua_thread.create(function()
        while true do
            wait(1000)
            for handle, tag in pairs(map.pool.bots) do
                if tag:find('tower_(.+)') then
                    local team = tag:match('tower_(.+)')
                    for target_ped, target_tag in pairs(map.pool.bots) do
                        local target_team = 'undefined'
                        if target_tag:find('(.+)_(.+)') then
                            local target_type, target_team = target_tag:match('(.+)_(.+)')
                            if target_type == 'creep' or target_type == 'player' then
                                if team ~= target_team or true then
                                    local pedX, pedY, pedZ = getCharCoordinates(handle)
                                    local targetX, targetY, targetZ = getCharCoordinates(target_ped)
                                    if getDistanceBetweenCoords3d(pedX, pedY, pedZ, targetX, targetY, targetZ) < 10 then
                                        local tower_s_x, tower_s_y = convert3DCoordsToScreen(pedX, pedY, pedZ)
                                        local target_s_x, target_s_y = convert3DCoordsToScreen(targetX, targetY, targetZ)
                                        renderDrawLine(tower_s_x, tower_s_y, target_s_x, target_s_y, 4, 0xCCff0000)
                                        local start = os.clock()
                                        local rocket = createObject(345, pedX, pedY, pedZ)
                                        setObjectCollision(rocket, false)
                                        table.insert(map.pool.objects, rocket)
                                        while start + 3 - os.clock() > 0 do
                                            wait(0) 
                                            if doesObjectExist(rocket) then
                                                local result, rocketX, rocketY, rocketZ = getObjectCoordinates(rocket)
                                                if result then
                                                    if getDistanceBetweenCoords3d(rocketX, rocketY, rocketZ, targetX, targetY, targetZ) < 0.5 then
                                                        deleteObject(rocket)
                                                        if target_ped == PLAYER_PED then
                                                            local_player.health = local_player.health - 50
                                                            sampAddChatMessage('damage deal', -1)
                                                        else 
                                                            map.set_hp(target_ped, getCharHealth(target_ped) - 50)
                                                        end
                                                    else
                                                        slideObject(rocket, targetX, targetY, targetZ, 0.1, 0.1, 0.1, false)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end 
    end)
end

AI.creep_loop = function(creep_handle, creep_side, creep_route_index)
    
end

return AI