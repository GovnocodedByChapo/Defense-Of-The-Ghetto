--[[
    items.lua:
        This file is a part of the DOTG1 mini-game.
        Author: chapo
        Last update: N/A
]] 

local local_player = require('DOTG1.local_player')
local movement = require('DOTG1.movement')
local map = require('DOTG1.map')
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
            lua_thread.create(function()
                while not wasKeyPressed(VK_LBUTTON) do 
                    wait(0)
                    local point, ped = movement.get_pointer_pos(), Vector3D(getCharCoordinates(PLAYER_PED))
                    map.drawCircleIn3d(ped.x, ped.y, ped.z, 14, 0xFF3fbf43, 3, 100)
                    local ped_2d_x, ped_2d_y = convert3DCoordsToScreen(ped.x, ped.y, ped.z)
                    local point_2d_x, point_2d_y = convert3DCoordsToScreen(point.x, point.y, point.z)
                    if getDistanceBetweenCoords3d(point.x, point.y, point.z, ped.x, ped.y, ped.z) <= 14 then
                        renderDrawLine(ped_2d_x, ped_2d_y, point_2d_x, point_2d_y, 3, 0xFF3fbf43)
                        map.drawCircleIn3d(point.x, point.y, point.z, 0.5, 0xFF3fbf43, 10, 100)
                    end
                end
                local point, ped = movement.get_pointer_pos(), Vector3D(getCharCoordinates(PLAYER_PED))
                if getDistanceBetweenCoords3d(point.x, point.y, point.z, ped.x, ped.y, ped.z) <= 14 then
                    setCharCoordinates(PLAYER_PED, point.x, point.y, point.z)
                end
                return
            end)
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
    if ITEMS.list[name] then
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
    return false, 'UNKNOWN_ITEM'
end

return ITEMS