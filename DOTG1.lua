local ffi = require('ffi')
local imgui = require('mimgui')

-->> load DOTG libs
--local core = require('DOTG1.core')
local map = require('DOTG1.map')

--local ui = require('DOTG1.ui')
--local net = core.net

-->> vars


-->> interface
--imgui.OnInitialize(function()
--    imgui.GetIO().IniFilename = nil
--
--    ui.init()
--end)
--

SIDE_GROOVE, SIDE_BALLAS = 0, 1

local ui_frame = imgui.OnFrame(
    function() 
        return true
    end,
    function(self)
        self.HideCursor = true--not select(2, ui.is_any_window_active())
        --ui.draw_ui_here()
        local pool = map.pool
        local DL = imgui.GetBackgroundDrawList()
        for index, ped in ipairs(pool.bots) do
            if doesCharExist(ped) and isCharOnScreen(ped) then
                local ped = Vector3D(getCharCoordinates(ped))
                local pos = imgui.ImVec2(convert3DCoordsToScreen(ped.x, ped.y, ped.z + 1))
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30 - 1, pos.y - 1), imgui.ImVec2(pos.x + 15 + 2, pos.y + 5 + 2), 0xFF000000, 5)
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30, pos.y), imgui.ImVec2(pos.x + 15, pos.y + 5), 0xFF0000ff, 5)
            end
        end
    end
)
--
---->> Event Handlers
--addEventHandler('onReceiveRpc',     function() net.raknet_handler() end)
--addEventHandler('onSendRpc',        function() net.raknet_handler() end)
--addEventHandler('onReceivePacket',  function() net.raknet_handler() end)
--addEventHandler('onSendPacket',     function() net.raknet_handler() end)
addEventHandler('onScriptTerminate', function(scr, quit)
    if scr == thisScript() then
        map.destroy_map()
        if not quit then
            --core.log('[FATAL ERROR] Script terminated (quit = false). Reloading...')
            thisScript():reload()
        end
    end
end)

local CCamera = getModuleHandle('samp.dll') + 0x9B5A0
ffi.cdef([[
    struct CVector { float x, y, z; }
]])

local Vector3D = require('vector3d')

local camera = {
    set_pos = function(vec3)
        local bs = raknetNewBitStream()
        raknetBitStreamWriteFloat(bs, vec3.x)
        raknetBitStreamWriteFloat(bs, vec3.y)
        raknetBitStreamWriteFloat(bs, vec3.z)
        raknetEmulRpcReceiveBitStream(157, bs)
        raknetDeleteBitStream(bs)
        
    end,
    look_at = function(vec3, cutType)
        local bs = raknetNewBitStream()
        raknetBitStreamWriteFloat(bs, vec3.x)
        raknetBitStreamWriteFloat(bs, vec3.y)
        raknetBitStreamWriteFloat(bs, vec3.z)
        raknetBitStreamWriteInt8(bs, cutType)
        raknetEmulRpcReceiveBitStream(158, bs)
        raknetDeleteBitStream(bs)
    end,
    pos = Vector3D(map.pos.x + 120, map.pos.y, map.pos.z),
    point = Vector3D(map.pos.x, map.pos.y, map.pos.z),
    zoom = 20
}

local movement = {
    go_to_coords = false,
    go_to_coords_coords = Vector3D(0, 0, 0),
    circles = {}
}

require('lib.moonloader')
-->> main zalupa
local go_game_process = false
function main()
    while not isSampAvailable() do wait(0) end
    map.init()
    sampRegisterChatCommand('map', function()
        lua_thread.create(function()
            map.create_map()
            map.teleport_player_to_map()
            wait(100)
            go_game_process = true
        end)
        
    end)
    camera.pos.z = camera.pos.z + camera.zoom
            

    while true do
        wait(0)
        draw_arrow_down(500, 500, 50, 3, 0xFFffffff)
        --printStyledString('CAM_POS X/Y: '..camera.pos.x..'/'..camera.pos.y, 50, 7)
        if go_game_process then

            map.bots_ai()
            if isKeyDown(VK_LMENU) then
                map.draw_building_circles()
            end
            camera.set_pos(camera.pos)
            camera.look_at(Vector3D(camera.pos.x - 20, camera.pos.y, camera.pos.z - camera.zoom), 0)
            setCameraPositionUnfixed(0, 3.15)

            -->> camera and movement
            showCursor(not isKeyDown(VK_MBUTTON))

            -->> point camera at PLAYER on TAB button
            if isKeyDown(VK_TAB) then
                local ped = Vector3D(getCharCoordinates(PLAYER_PED))
                camera.pos.x, camera.pos.y = ped.x + 15, ped.y
            end

            for i = 0, 20 do
                if isButtonPressed(Player, i) then
                    setGameKeyState(i, 0)
                end
            end

            if isKeyDown(VK_MBUTTON) then
                local mvx, mvy = getPcMouseMovement()
                camera.pos.y = camera.pos.y - mvx / 10
                camera.pos.x = camera.pos.x + mvy / 10
            else
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
                            sampAddChatMessage('ok', -1)
                        end
                    end
                end
            end

            -->> draw movement circles
            for index, data in ipairs(movement.circles) do
                drawCircleIn3d(data.pos.x, data.pos.y, data.pos.z, data.radius, join_argb(data.alpha, 0, 255, 0), 2, 100) 
                local sx, sy = convert3DCoordsToScreen(data.pos.x, data.pos.y, data.pos.z)
                local sy = sy - 15 + data.radius * 10
                renderDrawBox(sx - 2, sy - 10, 4, 10, join_argb(data.alpha, 0, 255, 0))
                renderDrawPolygon(sx, sy, 10, 10, 3, 180, join_argb(data.alpha, 0, 255, 0))

                movement.circles[index].radius = bringFloatTo(data.radius, 1, data.start, 0.7)
                movement.circles[index].alpha = bringFloatTo(data.alpha, 0, data.start, 0.7)
                if data.radius == 1 then
                    --movement.circles[index] = nil
                    --break
                end
                
            end
            
            if movement.go_to_coords then
                --movement.go_to_coords
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

addEventHandler('onWindowMessage', function(msg, param, param2)
    if msg == 0x020a --[[ WM_MOUSEWHEEL ]] then
        local Type = {
            Down = 4287102976,
            Up = 7864320
        }
        camera.pos.z = param == Type.Down and camera.pos.z + 2 or camera.pos.z - 2
        camera.pos.x = param == Type.Down and camera.pos.x + 2 or camera.pos.x - 2
    elseif msg == 0x0200 --[[WM_MOUSEMOVE]] then
        --print('WM_MM', param, param2) 
    end
end)

function draw_arrow_down(x, y, sizeY, width, col)

end

function drawCircleIn3d(x, y, z, radius, color, width, polygons) 
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