local Vector3D = require('vector3d')
local map = require('DOTG1.map')

MODULE = {
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

MODULE.update_camera = function()
    MODULE.set_pos(MODULE.pos)
    MODULE.look_at(Vector3D(MODULE.pos.x - 20, MODULE.pos.y, MODULE.pos.z - MODULE.zoom), 0)
    setCameraPositionUnfixed(0, 3.15)
    if isKeyDown(9) then
        local ped = Vector3D(getCharCoordinates(PLAYER_PED))
        MODULE.pos.x, MODULE.pos.y = ped.x + 15, ped.y
    end
end


local ffi = require('ffi')
ffi.cdef([[
    int GET_X_LPARAM(int);
    int GET_Y_LPARAM(int);
]])

addEventHandler('onWindowMessage', function(msg, param, lParam)
    if msg == 0x020a --[[ WM_MOUSEWHEEL ]] then
        local Type = {
            Down = 4287102976,
            Up = 7864320
        }
        MODULE.pos.z = param == Type.Down and MODULE.pos.z + 2 or MODULE.pos.z - 2
        MODULE.pos.x = param == Type.Down and MODULE.pos.x + 2 or MODULE.pos.x - 2
    elseif msg == 0x0200 --[[WM_MOUSEMOVE]] then
        --print('WM_MM', param, param2) 
        print('WM_MOUSEMOVE', ffi.C.GET_X_LPARAM(lParam), ffi.C.GET_Y_LPARAM(lParam))
    end
end)
