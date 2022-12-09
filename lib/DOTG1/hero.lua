local local_player = require('DOTG1.local_player')
local resource = require('DOTG1.resource')
local map = require('DOTG1.map')

ABILITY_TYPE = {
    ACTIVE = 0,
    PASSIVE = 1
}

MODULE_HERO = {
    HERO = {
        BIG_SMOKE = 1,
    }
}

local big_smoke = {

}

function puhlyash_coil_animation() -- unused
    if not hasAnimationLoaded('carry') then
        requestAnimation('carry')
    end
    clearCharTasksImmediately(PLAYER_PED)
    taskPlayAnim(PLAYER_PED, 'putdwn105', 'carry', 0, false, true, true, true, 10000)
end

local function get_coil_pos(dist)
    local angle = math.rad(getCharHeading(PLAYER_PED)) + math.pi / 2
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    local x, y, z = dist * math.cos(angle) + posX, dist * math.sin(angle) + posY, posZ
    return x, y, z
end

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
    },
    {
        name = 'SIDODJI',
        image = {},
        model = 0,
        damage = 30,
        hit_distance = 5,
        hit_speed = 0.6,
        weapon = 0,
        weapon_ammo = 1,
        max_health = 500,
        max_mana = 380,
        hit_animation = {
            file = 'grenade',
            name = 'weapon_throw'
        },
        abilities = {
            {
                name = '1',
                icon = 'NONE_',
                mana_required = 50,
                cooldown = 10,
                tooltip = '0.5m',
                callback = function()
                    lua_thread.create(function()
                        local x, y, z = get_coil_pos(3)
                        local smoke = createObject(18686, x, y, z)
                        map.deal_damage_to_point(Vector3D(x, y, z), 1, 50)
                        table.insert(map.pool.objects, smoke)
                        wait(3000)
                        deleteObject(smoke)
                    end)
                end
            },
            {
                name = '2',
                icon = 'NONE_',
                mana_required = 50,
                cooldown = 10,
                tooltip = '1.5m',
                callback = function()
                    lua_thread.create(function()
                        local x, y, z = get_coil_pos(6)
                        local smoke = createObject(18686, x, y, z)
                        map.deal_damage_to_point(Vector3D(x, y, z), 1, 50)
                        table.insert(map.pool.objects, smoke)
                        wait(3000)
                        deleteObject(smoke)
                    end)
                end
            },
            {
                name = '3',
                icon = 'NONE_',
                mana_required = 50,
                cooldown = 10,
                tooltip = '2.5m',
                callback = function()
                    lua_thread.create(function()
                        local x, y, z = get_coil_pos(9)
                        local smoke = createObject(18686, x, y, z)
                        map.deal_damage_to_point(Vector3D(x, y, z), 1, 50)
                        table.insert(map.pool.objects, smoke)
                        wait(3000)
                        deleteObject(smoke)
                    end)
                end
            },
            { -- ULT
                name = '3',
                icon = 'NONE_',
                mana_required = 50,
                cooldown = 10,
                tooltip = 'ULTIMATE BADABOOM',
                callback = function()
                    lua_thread.create(function()
                        local start = os.clock()
                        -- create object
                        while start + 4 - os.clock() < 0 do
                            wait(0)
                            -- move object
                        end
                    end)
                end
            },
        }
    }
}

MODULE_HERO.init = function()

end

return MODULE_HERO