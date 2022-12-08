local local_player = require('DOTG1.local_player')
local movement = require('DOTG1.movement')
ITEMS = {
    shop_menu = false
}

ITEMS.list = {
    ['Enchanted Mango'] = {
        name = 'mana',
        price = 100,
        description = 'regen 50 mana points',
        callback = function()
            local_player.mana = local_player.mana + 50
            if local_player.mana > local_player.max_mana then
                local_player.mana = local_player.max_mana
            end
        end
    },
    ['Faerie Fire'] = {
        name = 'Faerie Fire',
        price = 70,
        description = 'ћгновенно восстанавливает 85 здоровь€.',
        callback = function()
            local_player.health = local_player.health + 85
            if local_player.health > local_player.max_health then
                local_player.health = local_player.max_health
            end
        end
    },
    ['blink_dagger'] = {
        no_destroy_after_use = true,
        name = 'dagger',
        price = 100,
        mana_required = 0,
        cooldown = 15,
        callback = function()
            local pos = movement.get_pointer_pos()
            setCharCoordinates(PLAYER_PED, pos.x, pos.y, pos.z)
        end
    }
}

ITEMS.sell_item = function(name, slot)
    local_player.money = local_player.money + ITEMS.list[name].price / 2
    table.remove(local_player.items, slot)
end

ITEMS.buy_item = function(name)
    if #local_player.items >= 6 then
        return -1, 'NO_FREE_SPACE'
    end
    assert(ITEMS.list[name], 'incorrect item name in buy_item')
    local item = ITEMS.list[name]
    local new_item_index = -1
    if local_player.money - item.price >= 0 then
        local_player.money = local_player.money - item.price
        table.insert(local_player.items, name)
        new_item_index = #local_player.items
    end
    return new_item_index
end

ITEMS.use_item = function(name, slot_index, debug)
    if ITEMS.list[name].mana_required == nil or local_player.mana >= ITEMS.list[name].mana_required then
        if not ITEMS.list[name].no_destroy_after_use then
            table.remove(local_player.items, slot_index)
        end
        ITEMS.list[name].callback()
        return true, 'OK'
    else
        return false, 'NO_MANA_FOR_ITEM'
    end
end

return ITEMS