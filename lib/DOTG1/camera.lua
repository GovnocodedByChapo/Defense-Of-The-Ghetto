local Vector3D = require('vector3d')
local map = require('DOTG1.map')

MODULE_CAMERA = {
    set_pos = function(vec3)
        cameraResetNewScriptables()
        setFixedCameraPosition(vec3.x, vec3.y, vec3.z, 0, 0, 0)
        --[[
        local bs = raknetNewBitStream()
        raknetBitStreamWriteFloat(bs, vec3.x)
        raknetBitStreamWriteFloat(bs, vec3.y)
        raknetBitStreamWriteFloat(bs, vec3.z)
        raknetEmulRpcReceiveBitStream(157, bs)
        raknetDeleteBitStream(bs)
        ]]
    end,
    look_at = function(vec3, cutType)
        cameraResetNewScriptables()
        
        pointCameraAtPoint(vec3.x, vec3.y, vec3.z, 2)
        --[[

        local bs = raknetNewBitStream()
        raknetBitStreamWriteFloat(bs, vec3.x)
        raknetBitStreamWriteFloat(bs, vec3.y)
        raknetBitStreamWriteFloat(bs, vec3.z)
        raknetBitStreamWriteInt8(bs, cutType)
        raknetEmulRpcReceiveBitStream(158, bs)
        raknetDeleteBitStream(bs)

        ]]
    end,
    pos = Vector3D(map.pos.x + 120, map.pos.y, map.pos.z),
    point = Vector3D(map.pos.x, map.pos.y, map.pos.z),
    zoom = 20
}

MODULE_CAMERA.init = function()
    MODULE_CAMERA.pos.z = MODULE_CAMERA.pos.z + MODULE_CAMERA.zoom
end

MODULE_CAMERA.point_camera_to_player = function()
    local ped = Vector3D(getCharCoordinates(PLAYER_PED))
    MODULE_CAMERA.pos.x, MODULE_CAMERA.pos.y = ped.x + 15, ped.y
end

MODULE_CAMERA.update_camera = function()
    --print('CAMERA', MODULE_CAMERA.pos.x, MODULE_CAMERA.pos.y, MODULE_CAMERA.pos.z)
    lua_thread.create(function()
        MODULE_CAMERA.set_pos(MODULE_CAMERA.pos)
        wait(0)
        MODULE_CAMERA.look_at(Vector3D(MODULE_CAMERA.pos.x - 20, MODULE_CAMERA.pos.y, MODULE_CAMERA.pos.z - MODULE_CAMERA.zoom), 0)
        
    end)
    --setCameraPositionUnfixed(0, 3.15)
    if isKeyDown(9) then
        local ped = Vector3D(getCharCoordinates(PLAYER_PED))
        MODULE_CAMERA.pos.x, MODULE_CAMERA.pos.y = ped.x + 15, ped.y
    end

    local curX, curY = getCursorPos()
    local resX, resY = getScreenResolution()




    -->> point camera at PLAYER on TAB button
    if isKeyDown(VK_TAB) then MODULE_CAMERA.point_camera_to_player() end

    -->> move camera if cursor on screen corner
    local curX, curY = getCursorPos()
    local resX, resY = getScreenResolution()
    if curX <= 5 or curX >= resX - 5 then
        MODULE_CAMERA.pos.y = MODULE_CAMERA.pos.y + (curX <= 5 and -0.5 or 0.5)
    end
    if curY <= 5 or curY >= resY - 5 then
        MODULE_CAMERA.pos.x = MODULE_CAMERA.pos.x + (curY <= 5 and -0.5 or 0.5)
    end

    -->> move camera with mouse wheel
    if isKeyDown(VK_MBUTTON) then
        local mvx, mvy = getPcMouseMovement()
        MODULE_CAMERA.pos.y = MODULE_CAMERA.pos.y - mvx / 10
        MODULE_CAMERA.pos.x = MODULE_CAMERA.pos.x + mvy / 10
    end
end

addEventHandler('onWindowMessage', function(msg, param, lParam)
    if msg == 0x020a --[[ WM_MOUSEWHEEL ]] then
        local Type = {
            Down = 4287102976,
            Up = 7864320
        }
        MODULE_CAMERA.pos.z = param == Type.Down and MODULE_CAMERA.pos.z + 2 or MODULE_CAMERA.pos.z - 2
        MODULE_CAMERA.pos.x = param == Type.Down and MODULE_CAMERA.pos.x + 1 or MODULE_CAMERA.pos.x - 1
    end
end)

return MODULE_CAMERA