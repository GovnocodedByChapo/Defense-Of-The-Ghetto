--[[
    ui.lua:
        This file is a part of the DOTG1 mini-game.
        Author: chapo
        Last update: da idi ti nahui
]] 
GAME_STATE = { NONE = 0, MAIN_MENU = 1, HERO_SELECT = 2, IN_GAME = 3 }
local Vector3D = require('vector3d')
local imgui = require('mimgui')
local map = require('DOTG1.map')
local hero = require('DOTG1.hero')
local resource = require('DOTG1.resource')
local camera = require('DOTG1.camera')
local local_player = require('DOTG1.local_player')
local items = require('DOTG1.items')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8

MODULE_UI = { 
    font = {},
    image = {
        hero = {}
    } 
}

local index_names = {
    [1] = 'Q',
    [2] = 'W',
    [3] = 'E'
}

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end


MODULE_UI.draw_main_menu = function(hero_select_callback)
    local size = imgui.ImVec2(getScreenResolution())
    imgui.SetNextWindowSize(size, imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(0, 0), imgui.Cond.Always, imgui.ImVec2(0, 0))
    if imgui.Begin('dotg1_main_menu', _, imgui.WindowFlags.NoDecoration) then
        
        imgui.SetCursorPosY(size.y / 5)
        imgui.PushFont(MODULE_UI.font[40])
        imgui.CenterText('Defense Of The Ghetto')
        imgui.PopFont()
        imgui.SetCursorPosY(size.y / 5 + 30)
        imgui.CenterText('by chapo')

        if local_player.PLAYER.STATE == GAME_STATE.MAIN_MENU then
            imgui.SetCursorPosY(size.y / 5 + 50)
            imgui.PushFont(MODULE_UI.font[30])
            imgui.CenterText('CHOOSE MAP')
            imgui.PopFont()

            -->> play button
            local PLAY_BUTTON_SIZE = imgui.ImVec2(size.x / 8, size.y / 13)
            imgui.SetCursorPos(imgui.ImVec2(size.x - PLAY_BUTTON_SIZE.x - 25, size.y - PLAY_BUTTON_SIZE.y - 25))
            imgui.PushFont(MODULE_UI.font[20])
            if imgui.Button('PLAY', PLAY_BUTTON_SIZE) then
                local_player.PLAYER.STATE = GAME_STATE.HERO_SELECT
            end
            
            -->> map selector
            imgui.SetCursorPos(imgui.ImVec2(size.x / 3, size.y / 3))
            if imgui.BeginChild('maps_list', imgui.ImVec2(size.x / 3, size.x / 3), true) then
                for index, name in ipairs(map.get_maps_list()) do
                    imgui.SetCursorPosX(10)
                    imgui.PushStyleColor(imgui.Col.Button, local_player.PLAYER.selected_map == name and imgui.ImVec4(1, 1, 1, 0.3) or  imgui.GetStyle().Colors[imgui.Col.Button])
                    if imgui.Button(select(1, name:gsub('%.json', '')), imgui.ImVec2(size.x / 3 - 20, 40)) then
                        local_player.PLAYER.selected_map = name
                    end
                    imgui.PopStyleColor()
                end
                imgui.EndChild()
            end
            imgui.PopFont()
        else
            --imgui.Separator()
            imgui.SetCursorPosY(size.y / 5 + 50)
            imgui.PushFont(MODULE_UI.font[30])
            imgui.CenterText('CHOOSE YOUR HERO')
            imgui.PopFont()

            local start_pos = imgui.ImVec2(size.x / 2 - ((size.x / 8) / 2) * #hero.list, size.y / 2 - (size.y / 3) / 2)
            imgui.SetCursorPos(start_pos)
            for index, _hero in ipairs(hero.list) do
                if imgui.BeginChild('hero_select_'.._hero.name, imgui.ImVec2(size.x / 8, size.y / 3), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
                    local image_size = imgui.ImVec2(size.x / 8 - 10, size.y / 3 - 10)
                    
                   
                    imgui.SetCursorPos(imgui.ImVec2(0, 0))
                    local p = imgui.GetCursorScreenPos()
                    if imgui.ImageButton(MODULE_UI.image.hero[index].icon, image_size) then
                        hero_select_callback(index)
                    end
                    if imgui.IsItemHovered() then
                        imgui.BeginTooltip()
                        imgui.Text(_hero.name)
                        imgui.EndTooltip()
                        local cdl = imgui.GetWindowDrawList()
                        cdl:AddRectFilled(imgui.ImVec2(p.x, p.y + image_size.y / 1.1), imgui.ImVec2(p.x + image_size.x + 20, p.y + image_size.y + 10), 0xCC000000)--, float rounding = 0.0f, int rounding_corners_flags = ~0)
                        imgui.PushFont(MODULE_UI.font[25])
                        imgui.SetCursorPosY(image_size.y - 25)
                        imgui.CenterText(_hero.name)
                        imgui.PopFont()
                    end
                    
                    imgui.EndChild()
                end  
                if index < #hero.list then
                    imgui.SameLine()
                end
            end
        end
        imgui.End()
    end
end

MODULE_UI.draw_game_hud = function()
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(resX / 3, resY / 7), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY - resY / 7), imgui.Cond.Always, imgui.ImVec2(0.5, 0))
    if imgui.Begin('dotg1_hud', _, imgui.WindowFlags.NoDecoration) then
        local size = imgui.GetWindowSize()
        local bar_size_x = size.x - 10 - size.y

        imgui.SetCursorPos(imgui.ImVec2(10, 10))
        if imgui.BeginChild('player_image', imgui.ImVec2(size.y - 20, size.y - 20), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
            imgui.SetCursorPos(imgui.ImVec2(0, 0))
            imgui.Image(MODULE_UI.image.hero[local_player.PLAYER.hero_index].icon, imgui.ImVec2(size.y - 20, size.y - 20))
            imgui.EndChild()
        end
        if imgui.IsItemClicked() then
            camera.point_camera_to_player()
        end
        imgui.SameLine()
        for index, ability in ipairs(local_player.PLAYER.hero.abilities) do
            imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
            local aSize = imgui.ImVec2(size.y / 2, size.y / 2)
            if imgui.BeginChild('ability_'..tostring(index), aSize, true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
                imgui.SetCursorPos(imgui.ImVec2(0, 0))
                local _dl, _start = imgui.GetWindowDrawList(), imgui.GetCursorScreenPos()
                imgui.Image(MODULE_UI.image.hero[local_player.PLAYER.hero_index].ability[index], aSize)
                
                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                imgui.TextWrapped(tostring(index_names[index]))
               
                local cd = local_player.cooldown[index] + ability.cooldown - os.clock()
                if cd >= 0 then 
                    local cd_proc = aSize.x / 100 * math.floor(cd * 100 / ability.cooldown)
                    _dl:AddRectFilled(_start, imgui.ImVec2(_start.x + cd_proc, _start.y + aSize.y), 0xCC000000)

                    imgui.PushFont(MODULE_UI.font[20])
                    imgui.CenterText(tostring(math.ceil(cd))) 
                    imgui.PopFont()
                end

                -->> key tooltip
                
                imgui.EndChild()
            end
            imgui.PopStyleVar()
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(ability.name..'\n\n'..u8(ability.tooltip))
                imgui.EndTooltip()
            end
            if index < #local_player.PLAYER.hero.abilities then
                imgui.SameLine()
            end
        end

        

        imgui.SetCursorPos(imgui.ImVec2(10 + size.y - 20 + 10, size.y / 1.6))

        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.64, 0.03, 0.03, 1))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.22, 0.02, 0.02, 1))
        --imgui.SetCursorPosX(size.x / 2 - bar_size_x / 2)
        imgui.ProgressBar(math.floor(local_player.get('health') * 100 / local_player.get('max_health')) / 100, imgui.ImVec2(bar_size_x, 20))
        imgui.SameLine()
        imgui.PopStyleColor(3)
        imgui.CenterText(tostring(local_player.get('health')))
        imgui.SameLine(500)
        imgui.Text('+'..tostring(local_player.get('regen_health')))

        imgui.SetCursorPos(imgui.ImVec2(10 + size.y - 20 + 10, size.y / 1.6 + 25))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(0.11, 0.26, 1, 1))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.08, 0.12, 0.33, 1))
        imgui.ProgressBar(math.floor(local_player.get('mana') * 100 / local_player.get('max_mana')) / 100, imgui.ImVec2(bar_size_x, 20))
        imgui.SameLine()
        imgui.PopStyleColor(3)
        imgui.CenterText(tostring(local_player.get('mana')))
        imgui.SameLine(500)
        imgui.Text('+'..tostring(local_player.get('regen_mana')))

        imgui.SetCursorPos(imgui.ImVec2(size.x - 10 - 40, 10))
        if imgui.Button('CAM', imgui.ImVec2(40, 20)) then
            local_player.PLAYER.camera_mode = local_player.PLAYER.camera_mode == 0 and 1 or 0
            if local_player.PLAYER.camera_mode == 0 then
                camera.point_camera_to_player()
            elseif local_player.PLAYER.camera_mode == 1 then
                restoreCameraJumpcut()
            end
        end

        imgui.End()
    end
end

MODULE_UI.init = function()
    -->> fonts
    local defGlyph = imgui.GetIO().Fonts.ConfigData.Data[0].GlyphRanges
    local font_config = imgui.ImFontConfig()
    font_config.SizePixels = 14.0
    font_config.GlyphExtraSpacing.x = 0.1
    for _, size in ipairs({14, 20, 25, 30, 40}) do
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
            -->> abilities
            if MODULE_UI.image.hero[index].ability == nil then
                MODULE_UI.image.hero[index].ability = {}
            end
            for ab_index, ab_data in ipairs(resource.hero_icon[index].ability) do
                MODULE_UI.image.hero[index].ability[ab_index] = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', ab_data), #ab_data)
            end
        end
    end



    -->> items icons 
    for k, v in pairs(items.list) do
        if resource.item_icon[k] then
            local base85 = resource.item_icon[k]
            items.list[k].icon = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', base85), #base85)
        end
    end
end

MODULE_UI.draw_pause = function()

end

MODULE_UI.draw_shop_menu = function()
    local resX, resY = getScreenResolution()
    local sSize = imgui.ImVec2(resX / 4, resY / 1.3)
    imgui.SetNextWindowPos(imgui.ImVec2(resX, resY - 100), imgui.Cond.Always, imgui.ImVec2(1, 1))
    imgui.SetNextWindowSize(sSize, imgui.Cond.Always)
    if imgui.Begin('DOTG1_shop', _, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar) then
        local i = 0
        local icon_size = imgui.ImVec2(100, 75)
        for k, v in pairs(items.list) do
            i = i + 1
            if v.icon then
                imgui.Image(v.icon, icon_size)
            else 
                imgui.Button(k, icon_size)
            end
            if imgui.IsItemClicked() then
                items.buy_item(k)
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(('Price: %s\nDescription: %s'):format(v.price, u8(v.description or 'NONE')))
                imgui.EndTooltip()
            end
            if i ~= 3 then
                imgui.SameLine()
            end
        end
        imgui.End()
    end
end

MODULE_UI.draw_shop_button = function()
    if imgui.Begin('DOTG1_shop_button', nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
        local resX, resY = getScreenResolution()
        local s = imgui.GetWindowSize()
        imgui.SetWindowPosVec2(imgui.ImVec2(resX - s.x - 10, resY - s.y - 10))
        if imgui.Button('$'..tostring(local_player.money)) then
            items.shop_menu = not items.shop_menu
        end
        imgui.End()
    end
end

MODULE_UI.draw_health_bars = function(DL)
    for handle, tag in pairs(map.pool.bots) do
        local max_hp = handle == PLAYER_PED and local_player.max_health or 100
        if tag:find('creep_') then
            max_hp = 300
        end
        if doesCharExist(handle) and isCharOnScreen(handle) then
            local ped = Vector3D(getCharCoordinates(handle))

            local player = imgui.ImVec2(convert3DCoordsToScreen(ped.x, ped.y, ped.z + 1))

            local _start = imgui.ImVec2(player.x - 30, player.y - 3)
            local _end = imgui.ImVec2(player.x + 30, player.y + 3)

            
            local result, hp = pcall(getCharHealth, handle)
            if result then
                DL:AddRectFilled(_start, _end, 0xCC000000, 5)
                local health_end = (hp <= max_hp and hp or max_hp) * ((_end.x - _start.x) / max_hp )
                DL:AddRectFilled(imgui.ImVec2(_start.x + 1, _start.y + 1), imgui.ImVec2(_start.x + health_end - 1, _end.y - 1), 0xFF0000ff, 5)
                
            end
            DL:AddText(imgui.ImVec2(_end.x, _start.y), 0xFFffffff, result and tostring(hp)..'/'..tostring(max_hp) or 'none, '..tostring(ped))
            --math.floor(hp * 100 / max_hp)

           
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