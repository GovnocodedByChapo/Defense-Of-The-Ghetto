require('lib.moonloader')
local ffi = require('ffi')
local imgui = require('mimgui')
local Vector3D = require('vector3d')
local map = require('DOTG1.map')
local camera = require('DOTG1.camera')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
--local ui = require('DOTG1.ui')
--local net = core.net

SIDE_GROOVE, SIDE_BALLAS = 0, 1
local local_player = require('DOTG1.local_player')
local ui_frame = imgui.OnFrame(
    function() 
        return true
    end,
    function(self)
        self.HideCursor = true--not select(2, ui.is_any_window_active())
        
        --ui.draw_ui_here()
        local pool = map.pool
        local DL = imgui.GetBackgroundDrawList()
        for handle, tag in pairs(pool.bots) do
            if doesCharExist(handle) and isCharOnScreen(handle) then
                local ped = Vector3D(getCharCoordinates(handle))
                local pos = imgui.ImVec2(convert3DCoordsToScreen(ped.x, ped.y, ped.z + 1))
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30 - 1, pos.y - 1), imgui.ImVec2(pos.x + 15 + 2, pos.y + 5 + 2), 0xFF000000, 5)
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30, pos.y), imgui.ImVec2(pos.x + 15, pos.y + 5), 0xFF0000ff, 5)
                local result, hp = pcall(getCharHealth, handle)
                DL:AddText(pos, 0xFFffffff, result and tostring(hp) or 'none, '..tostring(ped))
            end
        end

        -->> abilities
        local resX, resY = getScreenResolution()
        imgui.SetNextWindowSize(imgui.ImVec2(resX / 3, resY / 7), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY - resY / 7), imgui.Cond.Always, imgui.ImVec2(0.5, 0))
        if imgui.Begin('ui', _, imgui.WindowFlags.NoDecoration) then
            local size = imgui.GetWindowSize()
            local bar_size_x = size.x - size.x / 4

            if imgui.BeginChild('ability_1', imgui.ImVec2(size.y / 2, size.y / 2), true) then
                imgui.Text('TWO #9')
                imgui.EndChild()
            end

            --imgui.BeginTooltip()
            --imgui.Text(u8'Временно увеличивает максимальное здоровье на 250\n\nДлительность: 3 сек')
            --imgui.EndTooltip()
            imgui.SameLine()
            if imgui.BeginChild('ability_2', imgui.ImVec2(size.y / 2, size.y / 2), true) then
                imgui.Text('BIG\nSMOKE\'s\nSMOKE')
                imgui.EndChild()
            end
            
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0))
            imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.64, 0.03, 0.03, 1))
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.22, 0.02, 0.02, 1))
            imgui.SetCursorPosX(size.x / 2 - bar_size_x / 2)
            imgui.ProgressBar(math.floor(local_player.get('health') * 100 / local_player.get('max_health')) / 100, imgui.ImVec2(bar_size_x, 20))
            imgui.SameLine()
            imgui.PopStyleColor(3)
            imgui.CenterText(tostring(local_player.get('health')))
            imgui.SameLine(500)
            imgui.Text('+'..tostring(local_player.get('regen_health')))

            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0))
            imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.11, 0.26, 1, 1))
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.08, 0.12, 0.33, 1))
            imgui.SetCursorPosX(size.x / 2 - bar_size_x / 2)
            imgui.ProgressBar(math.floor(local_player.get('mana') * 100 / local_player.get('max_mana')) / 100, imgui.ImVec2(bar_size_x, 20))
            imgui.SameLine()
            imgui.PopStyleColor(3)
            imgui.CenterText(tostring(local_player.get('mana')))
            imgui.SameLine(500)
            imgui.Text('+'..tostring(local_player.get('regen_mana')))
            
            imgui.End()
        end
    end
)

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

-->> Event Handlers
addEventHandler('onScriptTerminate', function(scr, quit)
    if scr == thisScript() then
        map.destroy_map()
        if not quit then
            --core.log('[FATAL ERROR] Script terminated (quit = false). Reloading...')
            thisScript():reload()
        end
    end
end)


ffi.cdef([[
    struct CVector { float x, y, z; }
]])


local movement = {
    go_to_coords = false,
    go_to_coords_coords = Vector3D(0, 0, 0),
    circles = {},
    target_handle = 1,
    last_hit = 0
}

local tower_ai_test = function()
    lua_thread.create(function()
        while true do
            wait(0)
            for handle, tag in pairs(map.pool.bots) do
                if tag:find('tower_(.+)') then
                    local team = tag:match('tower_(.+)')
                    -- find target for tower
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
                                        taskShootAtCoord(handle, targetX, targetY, targetZ, 1)
                                        wait(2500)
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

local GAME_PAUSED = false

local test_smoke_ability_1 = {
    name = 'two #9',
    mana_required = 50,
    callback = function()
        lua_thread.create(function()
            setPlayerModel(Player, 149)
            local_player.set('bigsmoke_ability_1', true)
            local_player.set('saved_max_health', local_player.get('max_health'))
            local_player.set('health', local_player.get('max_health') + 250)
            local_player.set('ability_active_1', true)
            local_player.set('ability_on_cooldown_1', true)
            wait(3000)
            setPlayerModel(Player, 269)
            local_player.set('bigsmoke_ability_1', false)
            local_player.set('health', local_player.get('saved_max_health'))
            local_player.set('ability_active_1', false)
            wait(10000)
            local_player.set('ability_on_cooldown_1', false)
        end)
    end
}

local test_smoke_ability_2 = {
    name = 'SMOKE',
    mana_required = 30,
    callback = function()
        lua_thread.create(function()
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local smoke = createObject(18715, x, y, z)
            table.insert(map.pool.objects, smoke)
            wait(3000)
            deleteObject(smoke)
        end)
    end
}



sp = function()
    --local no = createObject(11696, map.pos.x - 300 - 5, map.pos.y - 125, map.pos.z - 1)
    --table.insert(map.pool.objects, no)

    for i = 1, 8 do
        local no = createObject(17031, map.pos.x - 227, map.pos.y - 200 + 50 * i, map.pos.z - 1)
        setObjectScale(no, 1.5)
        table.insert(map.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, map.pos.x + 227, map.pos.y - 200 + 50 * i, map.pos.z - 1)
        setObjectHeading(no, 180)
        setObjectScale(no, 1.5)
        table.insert(map.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, map.pos.x - 200 + 50 * i, map.pos.y - 227, map.pos.z - 1)
        setObjectHeading(no, 90)
        setObjectScale(no, 1.5)
        table.insert(map.pool.objects, no)
    end
    for i = 1, 8 do
        local no = createObject(17031, map.pos.x - 200 + 50 * i, map.pos.y + 227, map.pos.z - 1)
        setObjectHeading(no, 270)
        setObjectScale(no, 1.5)
        table.insert(map.pool.objects, no)
    end

    local f = createObject(6965, map.pos.x, map.pos.y, map.pos.z + 1)
    table.insert(map.pool.objects, f)

    local f = createObject(9833, map.pos.x - 0.5, map.pos.y, map.pos.z + 9  )
    table.insert(map.pool.objects, f)

    local f = createObject(348, map.pos.x - 1.5, map.pos.y, map.pos.z + 15)
    setObjectRotation(f, 0, 270+45, 0)
    setObjectScale(f, 15)
    table.insert(map.pool.objects, f)

    local f = createObject(348, map.pos.x + 1.5, map.pos.y, map.pos.z + 15)
    setObjectRotation(f, 0, 270 + 45, 180)
    setObjectScale(f, 15)
    table.insert(map.pool.objects, f)
end 

-->> main zalupa
local go_game_process = false
function main()
    while not isSampAvailable() do wait(0) end
    
    map.init()
    camera.init()

    sampRegisterChatCommand('map', function()
        lua_thread.create(function()
            map.create_map()
            --map.teleport_player_to_map()
            setCharCoordinates(PLAYER_PED, 154, 5, 601)
            wait(500)
            go_game_process = true
            map.set_hp(PLAYER_PED, local_player.get('max_health'))
            giveWeaponToChar(PLAYER_PED, 8, 1)
            setCurrentCharWeapon(PLAYER_PED, 8)
        end)
    end)

    sampRegisterChatCommand('spawncreeps', function()
        map.spawn_creep_stack(SIDE_GROOVE, 3)
    end)
    sp()
    tower_ai_test()
    while true do
        wait(0)
        --print(local_player.get('mana'))
        if go_game_process then

            for handle, tag in pairs(map.pool.bots) do
                local curX, curY = getCursorPos()
                local x, y, z = getCharCoordinates(handle)
                local pedX, pedY = convert3DCoordsToScreen(x, y, z)
                
                
                if getDistanceBetweenCoords2d(curX, curY, pedX, pedY) < 50 then
                    drawShadow(3, x, y, z + 1, 0.0, 1, 1, 1, 0, 0) 
                    drawShadow(3, x, y, z + 1, 0.0, 1, 1, 1, 0, 0) 
                    drawShadow(3, x, y, z + 1, 0.0, 1, 1, 1, 0, 0) 
                    drawShadow(3, x, y, z + 1, 0.0, 1, 1, 1, 0, 0) 
                    
                    drawLightWithRange(x, y, z + 2, 255, 0, 0, 10)  -- 09E5
                    drawLightWithRange(x, y, z + 2, 255, 0, 0, 10)  -- 09E5
                    drawLightWithRange(x, y, z + 2, 255, 0, 0, 10)  -- 09E5
                    drawLightWithRange(x, y, z + 2, 255, 0, 0, 10)  -- 09E5
                end
            end

            map.draw_circle_on_target()
            local_player.loop()
            if wasKeyPressed(VK_Q) then
                local_player.use_ability(test_smoke_ability_1)
            elseif wasKeyPressed(VK_W) then
                local_player.use_ability(test_smoke_ability_2)
            elseif wasKeyPressed(VK_E) then
            end
            local curX, curY = getCursorPos()
            local resX, resY = getScreenResolution()
            --showCursor(not isKeyDown(VK_MBUTTON))
            --camera.update_camera()
            --map.bots_ai()
            if isKeyDown(VK_LMENU) then
                map.draw_building_circles()
            end
            
            -->> PED CONTROLS 
            do
                ---->> disable ped controls
                for i = 0, 20 do
                    if isButtonPressed(Player, i) then
                        setGameKeyState(i, 0)
                    end
                end

                ---->> ped movement (RMB)
                if wasKeyPressed(VK_RBUTTON) then
                    local curX, curY = getCursorPos()
                    local resX, resY = getScreenResolution()
                    local posX, posY, posZ = convertScreenCoordsToWorld3D(curX, curY, 700.0)
                    local camX, camY, camZ = camera.pos.x, camera.pos.y, camera.pos.z
                    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
                    if result and colpoint.entity ~= 0 then
                        local normal = colpoint.normal
                        local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                        local zOffset = 300
                        if normal[3] >= 0.5 then zOffset = 1 end
                        local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3, true, true, false, true, false, false, false)
                        if result then
                            pos = Vector3D(colpoint2.pos[1] + 1, colpoint2.pos[2] - 0.5, colpoint2.pos[3] + 1)

                            local beat_target = false
                            for handle, tag in pairs(map.pool.bots) do
                                if handle ~= PLAYER_PED then
                                    local x, y, z = getCharCoordinates(handle)
                                    if getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, x, y, z) < 1 then
                                        movement.target_handle = handle
                                        beat_target = true
                                        sampAddChatMessage('gotoped', -1)
                                    end
                                end
                            end
                            if not beat_target then
                                movement.target_handle = nil
                            end
                            
                            movement.go_to_coords = true
                            movement.go_to_coords_coords = pos
                            table.insert(movement.circles, {
                                pos = pos,
                                start = os.clock(),
                                radius = 0.5,
                                alpha = 255
                            })
                        end
                    end
                end

                ---->> draw movement circles
                for index, data in ipairs(movement.circles) do
                    if data.radius < 1 then
                        map.drawCircleIn3d(data.pos.x, data.pos.y, data.pos.z, data.radius, join_argb(data.alpha, 0, 255, 0), 2, 100) 
                        local sx, sy = convert3DCoordsToScreen(data.pos.x, data.pos.y, data.pos.z)
                        local sy = sy - 15 + data.radius * 10
                        renderDrawBox(sx - 2, sy - 10, 4, 10, join_argb(data.alpha, 0, 255, 0))
                        renderDrawPolygon(sx, sy, 10, 10, 3, 180, join_argb(data.alpha, 0, 255, 0))
                        movement.circles[index].radius = bringFloatTo(data.radius, 1, data.start, 0.7)
                        movement.circles[index].alpha = bringFloatTo(data.alpha, 0, data.start, 0.7)
                    end
                end

                if movement.go_to_coords then
                    local ped = Vector3D(getCharCoordinates(PLAYER_PED))
                    local go_to = Vector3D(movement.go_to_coords_coords.x,  movement.go_to_coords_coords.y,  movement.go_to_coords_coords.z)
                    
                    if movement.target_handle and movement.target_handle ~= PLAYER_PED then
                        if doesCharExist(movement.target_handle) then
                            go_to = Vector3D(getCharCoordinates(movement.target_handle))
                        else
                            movement.target_handle = nil
                        end
                    end
                    taskCharSlideToCoord(PLAYER_PED, go_to.x, go_to.y, go_to.z, getCharHeading(PLAYER_PED), 1)
                    setGameKeyState(16, 256)
                    if getDistanceBetweenCoords3d(ped.x, ped.y, ped.z, go_to.x,  go_to.y,  go_to.z) <= 1.5 then
                        if movement.target_handle then
                        --    local target = Vector3D(getCharCoordinates(movement.target_handle))
                        --    local player = Vector3D(getCharCoordinates(PLAYER_PED))
                        --    if getDistanceBetweenCoords3d(target.x, target.y, target.z, player.x, player.y, player.z) > 1 then
                        --       -- taskCharSlideToCoord(PLAYER_PED, target.x, target.y, target.z, getCharHeading(PLAYER_PED), 1)
                        --    else
                        --        --clearCharTasksImmediately(PLAYER_PED)     
                        --    end
                        else
                            movement.go_to_coords = false
                        end

                    end
                end

                if wasKeyPressed(49) then
                    setGameKeyState(17, 256)
                end

                -- fight with enemy
                if movement.target_handle and movement.target_handle ~= PLAYER_PED then
                    if doesCharExist(movement.target_handle) then


                        local target = Vector3D(getCharCoordinates(movement.target_handle))
                        local player = Vector3D(getCharCoordinates(PLAYER_PED))
                        if getDistanceBetweenCoords3d(target.x, target.y, target.z, player.x, player.y, player.z) <= 5 then
                            local fire_rate = 1
                            if movement.last_hit + 1 - os.clock() <= 0 then
                                movement.last_hit = os.clock()


                               
                                map.set_hp(movement.target_handle, getCharHealth(movement.target_handle) - 100) -- 20 - damage
                                if getCharHealth(movement.target_handle) <= 0 then
                                    map.pool.bots[movement.target_handle] = nil
                                    deleteChar(movement.target_handle)
                                    movement.target_handle = nil
                                    clearCharTasksImmediately(PLAYER_PED)
                                end
                                
                                sampAddChatMessage('HIT', -1)
                            end
                        end
                        local sx, sy = convert3DCoordsToScreen(target.x, target.y, target.z)
                        renderDrawPolygon(sx, sy, 20, 20, 10, 0, 0xFFff0000)
                    end
                end
            end
        end
    end
end





function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end