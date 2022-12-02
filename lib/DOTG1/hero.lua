local player = require('DOTG1.player')
local SELF_PLAYER = 1

MODULE = {
    HERO_BIG_SMOKE = 0,
}

MODULE.list = {
    [MODULE.HERO_BIG_SMOKE] = {
        model = 49,
        attached_objects = {},
        speed_multiplier = 1,
        atack_speed = 1,
        damage = 10,
        max_health = 1000,
        max_mana = 200,
        abilities = {
            {
                name = 'Big Smoke\'s Smoke',
                description = 'Creating smoke on the player',
                mana = 50,
                callback = function(data)
                    -- ability code
                end
            },
            {
                name = 'FATBOY',
                description = 'Adding 50% of max health for 5 seconds',
                mana = 50,
                callback = function(data)
                    lua_thread.create(function()
                        local max_health = player.get_player(1).max_health
                        player.set_player_max_health(1, max_health + max_health/ 2)
                        wait(5000 * 60)
                        player.set_player_max_health(1, max_health)
                    end)
                end
            }
        },
        loop = function() end
    }
}

return MODULE