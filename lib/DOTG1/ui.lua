--[[
    This file is a part of the DOTG1 mini-game.
    Author: chapo
    Last update: none
]] 
local Vector3D = require('vector3d')
local imgui = require('mimgui')
local map = require('DOTG1.map')
local hero = require('DOTG1.hero')
local resource = require('DOTG1.resource')

MODULE_UI = { 
    font = {},
    image = {
        hero = {}
    } 
}

MODULE_UI.init = function()
    -->> fonts
    local defGlyph = imgui.GetIO().Fonts.ConfigData.Data[0].GlyphRanges
    local font_config = imgui.ImFontConfig()
    font_config.SizePixels = 14.0
    font_config.GlyphExtraSpacing.x = 0.1
    for _, size in ipairs({14, 20, 25, 40}) do
        MODULE_UI.font[size] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebucbd.ttf', size, font_config, defGlyph)
    end

    -->> hero images
    for index, _hero in ipairs(hero.list) do
        if resource.hero_icon[index] then
            local player_image_base85 = resource.hero_icon[index].player
            if MODULE_UI.image.hero[index] == nil then
                MODULE_UI.image.hero[index] = {}
            end
            MODULE_UI.image.hero[index].icon = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', player_image_base85), #player_image_base85)
        end
    end
end

MODULE_UI.draw_health_bars = function(DL)
    for handle, tag in pairs(map.pool.bots) do
        local max_hp = 100
        if tag:find('creep_') then
            max_hp = 300
        end
        if doesCharExist(handle) and isCharOnScreen(handle) then
            local ped = Vector3D(getCharCoordinates(handle))
            local _pos = imgui.ImVec2(convert3DCoordsToScreen(ped.x, ped.y, ped.z + 1))
            local pos = imgui.ImVec2(_pos.x - 30, _pos.y)
            local result, hp = pcall(getCharHealth, handle)
            if result then
                DL:AddRectFilled(imgui.ImVec2(pos.x - 30 - 1, pos.y - 1), imgui.ImVec2(pos.x + 15 + 2, pos.y + 5 + 2), 0xCC000000, 5)
                DL:AddRectFilled(pos, imgui.ImVec2(pos.x + math.floor(hp * 100 / max_hp) / 100, pos.y + 5), 0xFF0000ff, 5)
            end

            --math.floor(hp * 100 / max_hp)

            DL:AddText(pos, 0xFFffffff, result and tostring(hp) or 'none, '..tostring(ped))
        end
    end
end

MODULE_UI.is_any_window_active = function()
    local draw, show_cursor = false, false
    for k, v in ipairs(MODULE_UI.list) do
        if v.condition then
            draw = true
            if v.show_cursor then
                show_cursor = true
            end
        end
    end
    return draw, show_cursor
end

return MODULE_UI