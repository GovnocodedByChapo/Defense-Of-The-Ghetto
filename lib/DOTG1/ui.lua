--[[
    This file is a part of the DOTG1 mini-game.
    Author: chapo
    Last update: none
]] 
local Vector3D = require('vector3d')
local imgui = require('mimgui')
MODULE = {}
MODULE.list = {
    {
        name = 'player_abilities',
        condition = true,
        show_cursor = true,
        frame = function()
            if imgui.Begin('window_title') then
                imgui.End()
            end
        end
    }
}

MODULE.init = function()

end

local pool = require('DOTG1.map').pool

MODULE.draw_health_bars = function(DL)
    for index, ped in ipairs(pool.bots) do
        if doesCharExist(ped) then
            local pos = imgui.ImVec2(convert3DCoordsToScreen(getCharCoordinates(ped)))
            DL:AddRectFilled(pos, imgui.ImVec2(pos.x + 100, pos.y + 20), 0xFF0000ff, 5)
        end
    end
end

MODULE.is_any_window_active = function()
    local draw, show_cursor = false, false
    for k, v in ipairs(MODULE.list) do
        if v.condition then
            draw = true
            if v.show_cursor then
                show_cursor = true
            end
        end
    end
    return draw, show_cursor
end

return MODULE