--[[
    This file is a part of the DOTG1 mini-game.
    Author: chapo
    Last update: none
]] 
GAME_STATE = { NONE = 0, MAIN_MENU = 1, HERO_SELECT = 2, IN_GAME = 3 }
local Vector3D = require('vector3d')
local imgui = require('mimgui')
local map = require('DOTG1.map')
local hero = require('DOTG1.hero')
local resource = require('DOTG1.resource')
local camera = require('DOTG1.camera')
local local_player = require('DOTG1.local_player')
MODULE_UI = { 
    font = {},
    image = {
        hero = {}
    } 
}

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
            local PLAY_BUTTON_SIZE = imgui.ImVec2(size.x / 8, size.y / 13)
            imgui.SetCursorPos(imgui.ImVec2(size.x - PLAY_BUTTON_SIZE.x - 25, size.y - PLAY_BUTTON_SIZE.y - 25))

            imgui.PushFont(MODULE_UI.font[20])
            if imgui.Button('PLAY', PLAY_BUTTON_SIZE) then
                local_player.PLAYER.STATE = GAME_STATE.HERO_SELECT
            end
            imgui.PopFont()
        else
            --imgui.Separator()
            imgui.SetCursorPosY(size.y / 5 + 50)
            imgui.PushFont(MODULE_UI.font[40])
            imgui.CenterText('CHOOSE YOUR HERO')
            imgui.PopFont()

            local start_pos = imgui.ImVec2(size.x / 2 - ((size.x / 8) / 2) * #hero.list, size.y / 2 - (size.y / 3) / 2)
            imgui.SetCursorPos(start_pos)
            for index, _hero in ipairs(hero.list) do
                if imgui.BeginChild('hero_select_'.._hero.name, imgui.ImVec2(size.x / 8, size.y / 3), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse) then
                    local image_size = imgui.ImVec2(size.x / 8 - 10, size.y / 3 - 10)
                    
                    imgui.SetCursorPos(imgui.ImVec2(5, 5))
                    imgui.InvisibleButton('hero_select_'.._hero.name..'_HOVER_ZONE', imgui.ImVec2(size.x / 8 - 10, size.y / 3 - 10))
                    if imgui.IsItemHovered() then
                        image_size = imgui.ImVec2(size.x / 8, size.y / 3)
                    end
                    imgui.SetCursorPos(imgui.IsItemHovered() and imgui.ImVec2(0, 0) or imgui.ImVec2(5, 5))
                    imgui.Image(MODULE_UI.image.hero[1].icon, image_size)
                    if imgui.IsItemHovered() then
                        imgui.BeginTooltip()
                        imgui.Text(_hero.name)
                        imgui.EndTooltip()
                        
                    end
                    if imgui.IsMouseClicked(0) then
                        hero_select_callback(index)
                        
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
            imgui.Image(MODULE_UI.image.hero[1].icon, imgui.ImVec2(size.y - 20, size.y - 20))
            imgui.EndChild()
        end
        if imgui.IsItemClicked() then
            camera.point_camera_to_player()
        end
        imgui.SameLine()
        for index, ability in ipairs(PLAYER.hero.abilities) do
            if imgui.BeginChild('ability_'..tostring(index), imgui.ImVec2(size.y / 2, size.y / 2), true) then
                imgui.TextWrapped(tostring(ability.name))

                local cd = local_player.cooldown[index] + ability.cooldown - os.clock()
                if cd >= 0 then
                    imgui.Text('CD: '..tostring(local_player.cooldown[index] + ability.cooldown - os.clock()))
                end
                imgui.EndChild()
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(ability.name..'\n\n'..u8(ability.tooltip))
                imgui.EndTooltip()
            end
            if index < #PLAYER.hero.abilities then
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
            PLAYER.camera_mode = PLAYER.camera_mode == 0 and 1 or 0
            if PLAYER.camera_mode == 0 then
                camera.point_camera_to_player()
            elseif PLAYER.camera_mode == 1 then
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