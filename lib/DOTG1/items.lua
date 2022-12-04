local local_player = require('DOTG1.local_player')
ITEMS = {}

ITEMS.list = {
    ['mana_refill'] = {
        name = 'mana',
        price = 100,
        description = 'regen 50 mana points',
        callback = function()
            local_player.set('mana', local_player.get('mana') + 50)
            if local_player.get('mana') > local_player.get('max_mana') then
                local_player.set('mana', local_player.get('max_mana'))
            end
        end
    }
}

ITEMS.use_item = function(name, debug)
    if not debug then
        if local_player.money >= ITEMS.list[name].price then
            local_player.money = local_player.money - 100
        else
            return sampAddChatMessage('NO MONEY', -1)
        end
    end
    ITEMS.list[name].callback()
end

return ITEMS