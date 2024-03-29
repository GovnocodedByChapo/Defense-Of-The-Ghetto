--[[
    local_player.lua:
        This file is a part of the DOTG1 mini-game.
        Author: chapo
        Last update: N/A
]] 
GAME_STATE = { NONE = 0, MAIN_MENU = 1, HERO_SELECT = 2, IN_GAME = 3 }
LOCAL_PLAYER = {
    PLAYER = {
        STATE = GAME_STATE.NONE,
        selected_map = 'none',
        hero = 1,
        team = 0,
        camera_mode = 0,
        debuff = {},
        saved_pos = Vector3D(0, 0, 3)
    },
    v = {},
    max_health = 500,
    health = 500,
    max_mana = 300,
    mana = 300,
    model = 269,
    regen_mana = 1.5,
    regen_health = 2,
    saved = {},
    regen_last = 0,
    cooldown = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
        [4] = 0,
        [5] = 0
    },
    money = 600,
    items = {}
}


LOCAL_PLAYER.use_ability = function(ability, index)
    if ability then
        if ability.type == nil or ability.type == 0 then
            if LOCAL_PLAYER.mana >= ability.mana_required then
                if LOCAL_PLAYER.cooldown[index] + ability.cooldown - os.clock() <= 0 then
                    LOCAL_PLAYER.cooldown[index] = os.clock()
                    local result = ability.callback()
                    if result == nil or result == true then
                        LOCAL_PLAYER.mana = LOCAL_PLAYER.mana - ability.mana_required   
                        return true, 'OK'
                    elseif result == false then
                        return false, 'canceled_by_ability'
                    end
                else
                    sampAddChatMessage('COOLDOWN, WAIT', -1)
                    return false, 'COOLDOWN'
                end
            else
                sampAddChatMessage('no mana, retard.', -1)
                return false, 'NO_MANA'
            end
        else
            sampAddChatMessage('error, ability is passive', -1)
        end
    end
    return false, 'ACTION_IGNORED'
end

LOCAL_PLAYER.get = function(key)
    if key and LOCAL_PLAYER[key] then
        return LOCAL_PLAYER[key]
    end
end

LOCAL_PLAYER.set = function(key, value)
    LOCAL_PLAYER[key] = value
end

LOCAL_PLAYER.loop = function()
    
    if LOCAL_PLAYER.get('regen_last') + 1 < os.clock() then
        LOCAL_PLAYER.money = LOCAL_PLAYER.money + 2
        LOCAL_PLAYER.set('regen_last', os.clock())
        local new_health, new_mana = LOCAL_PLAYER.get('health') + LOCAL_PLAYER.get('regen_health'), LOCAL_PLAYER.get('mana') + LOCAL_PLAYER.get('regen_mana')
        if new_health <= LOCAL_PLAYER.get('max_health') then
            LOCAL_PLAYER.set('health', new_health)
        end
        if new_mana <= LOCAL_PLAYER.get('max_mana') then
            LOCAL_PLAYER.set('mana', new_mana)
        end
    end
end

return LOCAL_PLAYER