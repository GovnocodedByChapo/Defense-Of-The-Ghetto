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
        model = 5,
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
                        local smoke = createObject(18686, x, y, z - 1)
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 1, 50)
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
                        local smoke = createObject(18686, x, y, z - 1)
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 1, 50)
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
                tooltip = 'Shadow Fiend razes the ground directly in front of him, dealing damage to enemy units in the area. Adds a stacking damage amplifier on the target that causes the enemy to take bonus Shadowraze damage per stack. Each consecutive stack also decreases turn rate and movement speed.\n\nDamage: 50\nDistance: 2.5m',
                callback = function()
                    lua_thread.create(function()
                        local x, y, z = get_coil_pos(9)
                        local smoke = createObject(18686, x, y, z - 1)
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 1, 50)
                        table.insert(map.pool.objects, smoke)
                        wait(3000)
                        deleteObject(smoke)
                    end)
                end
            },
            { -- ULT
                name = 'REQUIEM OF SOULS',
                icon = 'NONE_',
                mana_required = 125,
                cooldown = 110,
                tooltip = 'Shadow Fiend gathers his captured souls to release them as lines of demonic energy. Units near Shadow Fiend when the souls are released can be damaged by several lines of energy. Any unit damaged by Requiem of Souls will be feared and have its movement speed and magic resistance reduced for 0.9 seconds for each line hit up to a maximum of 2.7. Lines of energy are created for every soul captured through Necromastery.\nRequiem of Souls is automatically cast whenever Shadow Fiend dies, regardless of its cooldown.\n\nDamage: 55',
                callback = function()
                    lua_thread.create(function()
                        local start = os.clock()
                        local ultimate_objects = {}
                        
                        for i = 0, 360, 30 do
                            local angle = math.rad(i) + math.pi / 2
                            local posX, posY, posZ = getCharCoordinates(PLAYER_PED)

                            local start = Vector3D(1 * math.cos(angle) + posX, 1 * math.sin(angle) + posY, posZ - 1)
                            local stop = Vector3D(20 * math.cos(angle) + posX, 20 * math.sin(angle) + posY, posZ - 1)
                            local handle = createObject(18686, start.x, start.y, start.z)
                            ultimate_objects[handle] = {
                                start = start,
                                stop = stop
                            }
                            table.insert(map.pool.objects, handle)
                        end

                        -- create object
                        while start + 4 - os.clock() > 0 do
                            wait(0)
                            for handle, data in pairs(ultimate_objects) do
                                if doesObjectExist(handle) then
                                    slideObject(handle, data.stop.x, data.stop.y, data.stop.z, 0.5, 0.5, 0.5, false)
                                    local result, x, y, z = getObjectCoordinates(handle)
                                    if result then
                                        map.deal_damage_to_point(Vector3D(x, y, z), 1, 55)
                                    end
                                end
                            end
                        end
                        for handle, data in pairs(ultimate_objects) do
                            if doesObjectExist(handle) then
                                deleteObject(handle)
                                ultimate_objects[handle] = nil
                                --for k, v in ipairs(map.pool.objects) do
                                --    if v == handle then
                                --        map.pool.objects[k] = nil
                                --    end
                                --end
                            end
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