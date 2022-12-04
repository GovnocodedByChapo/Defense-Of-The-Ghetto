local local_player = require('DOTG1.local_player')
local resource = require('DOTG1.resource')
local map = require('DOTG1.map')
MODULE_HERO = {
    HERO = {
        BIG_SMOKE = 1,
    }
}

MODULE_HERO.list = {
    {
        name = 'Big Smoke',
        image = {},
        model = 149,
        damage = 30,
        hit_distance = 1.4,
        hit_speed = 1,
        weapon = 5,
        weapon_ammo = 1,
        max_health = 500,
        max_mana = 380,
        hit_animation = {
            file = 'BASEBALL',
            name = 'BAT_1'
        },
        abilities = {
            {
                name = 'TWO #9',
                icon = 'NONE_',
                mana_required = 50,
                cooldown = 10,
                tooltip = 'FISRT',
                callback = function()
                    lua_thread.create(function()
                        setPlayerModel(Player, 149)
                        local_player.set('bigsmoke_ability_1', true)
                        local_player.set('saved_max_health', local_player.get('max_health'))
                        local_player.set('health', local_player.get('max_health') + 250)
                        local_player.set('ability_active_1', true)
                        local_player.set('ability_on_cooldown_1', true)
                        wait(3000)
                        setPlayerModel(Player, 269)
                        local_player.set('bigsmoke_ability_1', false)
                        local_player.set('health', local_player.get('saved_max_health'))
                        local_player.set('ability_active_1', false)
                        wait(10000)
                        local_player.set('ability_on_cooldown_1', false)
                    end)
                end
            },
            -- SMOKE
            {
                name = 'Big Smoke\'s Smoke',
                icon = 'NONE_',
                mana_required = 30,
                cooldown = 10,
                tooltip = 'SECOND',
                callback = function()
                    lua_thread.create(function()
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local smoke = createObject(18715, x, y, z)
                        table.insert(map.pool.objects, smoke)
                        wait(3000)
                        deleteObject(smoke)
                    end)
                end
            },
        }
    }
}

MODULE_HERO.init = function()

end

return MODULE_HERO