--[[
    This file is a part of the DOTG1 mini-game.
    Author: chapo
    Last update: none
]] 

MODULE = {}
MODULE.list = {
    {
        name = 'main_menu',
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