local local_player = require('DOTG1.local_player')
local resource = require('DOTG1.resource')
local map = require('DOTG1.map')
local movement = require('DOTG1.movement')

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
        name = 'Samp Funcs',
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
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 3, 50, false)
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
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 3, 50, false)
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
                        map.deal_damage_to_point(Vector3D(x, y, z - 1), 3, 50, false)
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
                                        map.deal_damage_to_point(Vector3D(x, y, z), 3, 55)
                                    end
                                end
                            end
                        end
                        for handle, data in pairs(ultimate_objects) do
                            if doesObjectExist(handle) then
                                deleteObject(handle)
                                ultimate_objects[handle] = nil
                            end
                        end
                    end)
                end
            },
        }
    },
    {
        name = 'Sniper',
        image = {},
        model = 294,
        damage = 30,
        hit_distance = 14,
        hit_speed = 1,
        weapon = 34,
        weapon_ammo = 999,
        max_health = 580,
        max_mana = 255,
        hit_animation = {
            file = 'UZI',--'SILENCED',
            name = 'UZI_FIRE',--'SILENCE_FIRE'
        },
        abilities = {
            {
                name = 'SHRAPNEL',
                icon = 'NONE_',
                mana_required = 75,
                cooldown = 23,
                tooltip = 'Consumes a charge to launch a ball of shrapnel that showers the target area in explosive pellets. Enemies are subject to damage and slowed movement. Reveals the targeted area. Shrapnel charges restore every 35.0 seconds.',
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
                                map.drawCircleIn3d(point.x, point.y, point.z, 5, 0xFFff0000, 2, 50)
                            end
                        end
                        local start, last_damage = os.clock(), 0
                        local duration = 10
                        local pos = movement.get_pointer_pos()

                        while start + 10 - os.clock() > 0 do
                            wait(0)
                            map.drawCircleIn3d(pos.x, pos.y, pos.z, 5, 0xFFff0000, 2, 50)
                            if last_damage + 0.7 - os.clock() <= 0 then
                                map.deal_damage_to_point(pos, 5, 13, false)
                                last_damage = os.clock()
                            end
                        end
                    end)
                end
            },
            {
                name = 'HEADSHOT',
                icon = 'NONE_',
                mana_required = 30,
                cooldown = 10,
                tooltip = 'Sniper increases his accuracy, giving him a chance to deal extra damage and knock back his enemies. Headshots briefly slow enemy movement and attack speed by -100.0%.\n\nCHANCE: 40%',
                callback = function()
                    local r = math.random(0, 100)
                    if r <= 40 then

                    end
                end
            },
        }
    },
}

MODULE_HERO.init = function()

end

return MODULE_HERO