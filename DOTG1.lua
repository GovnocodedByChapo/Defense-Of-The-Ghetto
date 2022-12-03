require('lib.moonloader')
local ffi = require('ffi')
local imgui = require('mimgui')
local Vector3D = require('vector3d')
local map = require('DOTG1.map')
local camera = require('DOTG1.camera')

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
        for ped, tag in pairs(pool.bots) do
            if doesCharExist(ped) and isCharOnScreen(ped) then
                local ped = Vector3D(getCharCoordinates(ped))
                local pos = imgui.ImVec2(convert3DCoordsToScreen(ped.x, ped.y, ped.z + 1))
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30 - 1, pos.y - 1), imgui.ImVec2(pos.x + 15 + 2, pos.y + 5 + 2), 0xFF000000, 5)
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30, pos.y), imgui.ImVec2(pos.x + 15, pos.y + 5), 0xFF0000ff, 5)
                DL:AddText(pos, 0xFFffffff, tostring(getCharHealth(PLAYER_PED)))
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
    circles = {}
}

local tower_ai_test = function()
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
                            local pedX, pedY, pedZ = getCharCoordinates(target_ped)
                            local targetX, targetY, targetZ = getCharCoordinates(handle)
                            if getDistanceBetweenCoords3d(pedX, pedY, pedZ, targetX, targetY, targetZ - 13) < 10 then
                                local tower_s_x, tower_s_y = convert3DCoordsToScreen(pedX, pedY, pedZ)
                                local target_s_x, target_s_y = convert3DCoordsToScreen(targetX, targetY, targetZ)
                                renderDrawLine(tower_s_x, tower_s_y, target_s_x, target_s_y, 4, 0xCCff0000)
                                taskShootAtCoord(handle, targetX, targetY, targetZ, 1000)
                                --wait(1050)
                            end
                        end
                    end
                end
            end
        end
    end
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


-->> main zalupa
local go_game_process = false
function main()
    while not isSampAvailable() do wait(0) end
    map.init()
    camera.init()
    sampRegisterChatCommand('map', function()
        lua_thread.create(function()
            map.create_map()
            map.teleport_player_to_map()
            wait(500)
            go_game_process = true
        end)
    end)

    sampRegisterChatCommand('spawncreeps', function()
        map.spawn_creep_stack(SIDE_GROOVE, 3)
    end)
    
    while true do
        wait(0)
        print(local_player.get('mana'))
        if go_game_process then
            local_player.loop()
            if wasKeyPressed(VK_Q) then
                local_player.use_ability(test_smoke_ability_1)
            elseif wasKeyPressed(VK_W) then
                local_player.use_ability(test_smoke_ability_2)
            elseif wasKeyPressed(VK_E) then
            end
            local curX, curY = getCursorPos()
            local resX, resY = getScreenResolution()
            showCursor(not isKeyDown(VK_MBUTTON))
            camera.update_camera()
            --map.bots_ai()
            if isKeyDown(VK_LMENU) then
                map.draw_building_circles()
            end
            tower_ai_test()
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
                    if data.radius > 0 then
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
                    taskCharSlideToCoord(PLAYER_PED, movement.go_to_coords_coords.x,  movement.go_to_coords_coords.y,  movement.go_to_coords_coords.z, getCharHeading(PLAYER_PED), 1)
                    setGameKeyState(16, 256)
                    if getDistanceBetweenCoords3d(ped.x, ped.y, ped.z ,movement.go_to_coords_coords.x,  movement.go_to_coords_coords.y,  movement.go_to_coords_coords.z) <= 1 then
                        movement.go_to_coords = false
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