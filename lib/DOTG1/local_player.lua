LOCAL_PLAYER = {}

LOCAL_PLAYER = {
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
        [2] = 0
    }
}

LOCAL_PLAYER.use_ability = function(ability, index)
    if ability then
        if LOCAL_PLAYER.mana >= ability.mana_required then
            if LOCAL_PLAYER.cooldown[index] + ability.cooldown - os.clock() <= 0 then
                LOCAL_PLAYER.cooldown[index] = os.clock()
                ability.callback()
                LOCAL_PLAYER.mana = LOCAL_PLAYER.mana - ability.mana_required
                return true, 'OK'
            else
                sampAddChatMessage('COOLDOWN, WAIT', -1)
                return false, 'COOLDOWN'
            end
        else
            sampAddChatMessage('no mana, retard.', -1)
            return false, 'NO_MANA'
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