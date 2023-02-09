local local_player = require('DOTG1.local_player')
--local resource = require('DOTG1.resource')
local map = require('DOTG1.map')
local movement = require('DOTG1.movement')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8



MODULE_HERO = {
    HERO = {
        BIG_SMOKE = 1,
    },
    ABILITY_TYPE = {
        ACTIVE = 0,
        PASSIVE = 1
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

--[[
    HERO TABLE TEMPLATE
    {
        name = 'HeroName',
        image = nil,
        model = 269,
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
                name = 'First',
                 icon = nil,
                mana_required = 50,
                cooldown = 10,
                tooltip = 'FISRT',
                callback = function()
                    -- ability 1 callback
                end
            },
            {
                name = 'Second',
                 icon = nil,
                mana_required = 30,
                cooldown = 10,
                tooltip = 'SECOND',
                callback = function()
                    -- ability 2 callback
                end
            },
            {
                name = 'The third',
                 icon = nil,
                mana_required = 30,
                cooldown = 10,
                tooltip = 'SECOND',
                callback = function()
                    -- ability 2 callback
                end
            },
            {
                name = 'Ultimate',
                 icon = nil,
                mana_required = 30,
                cooldown = 10,
                tooltip = 'SECOND',
                callback = function()
                    -- ability 2 callback
                end
            },
        }
    },
]]

function getTargetFromPointer()

end
local ffi = require('ffi')
local CPed_SetModelIndex = ffi.cast('void(__thiscall *)(void*, unsigned int)', 0x5E4880)
function setCharModel(ped, model)
    assert(doesCharExist(ped), 'ped not found')
    if not hasModelLoaded(model) then
        requestModel(model)
        loadAllModelsNow()
    end
    CPed_SetModelIndex(ffi.cast('void*', getCharPointer(ped)), ffi.cast('unsigned int', model))
end

function getNearestPedFromPos(pos)
    local ped, dist = PLAYER_PED, 999999
    for k, v in ipairs(getAllChars()) do
        local x, y, z = getCharCoordinates(v)
        local _dist = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, x, y, z)
        if _dist < dist then
            ped, dist = v, _dist
        end
    end
    return ped, dist
end

HERO_LION = {
    name = 'LION',
    image = nil,
    model = 62,
    damage = 30,
    hit_distance = 1.4,
    hit_speed = 1,
    weapon = 15,
    weapon_ammo = 1,
    max_health = 420,
    max_mana = 440,
    hit_animation = {
        file = 'BASEBALL',
        name = 'BAT_1'
    },
    abilities = {
        {
            name = 'Earth Spike',
            icon = nil,
            mana_required = 85,
            cooldown = 12,
            tooltip = 'Из земли прорывается полоса каменных шипов. Они подбрасывают врагов в воздух, а по приземлении оглушают их и наносят урон.',
            callback = function()
                lua_thread.create(function()
                    local start = os.clock()
                    local x, y, z = get_coil_pos(3)
                    local spikes1 = createObject(1408, x, y, z - 1)
                    local x, y, z = get_coil_pos(5)
                    local spikes2 = createObject(1408, x, y, z - 1)
                    setObjectHeading(spikes1, getCharHeading(PLAYER_PED) + 90)
                    setObjectHeading(spikes2, getCharHeading(PLAYER_PED) + 90)
                    for i = 1, 5 do
                        map.deal_damage_to_point(Vector3D(get_coil_pos(i)), 3, 50, false)
                    end
                    wait(3000)
                    deleteObject(spikes1)
                    deleteObject(spikes2)
                end)
            end
        },
        {
            name = 'Hex',
            icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'Превращает врага в безобидную зверюшку, блокируя все его способности.',
            callback = function()
                lua_thread.create(function()
                    local ped = nil
                    while not wasKeyPressed(1) do 
                        wait(0)
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        map.drawCircleIn3d(x, y, z, 4, 0xCC04ff00, 2)
                        ped = getNearestPedFromPos(movement.get_pointer_pos())
                    end
                    if not ped then return false end
                    if ped == PLAYER_PED then
                        sampAddChatMessage('error, no target for "HEX"', -1)
                        return false
                    end
                    local start = os.clock()
                    local defModel = getCharModel(ped)
                    setCharModel(ped, 264)
                    while start + 3 - os.clock() > 0 do wait(0) end
                    if doesCharExist(ped) then
                        setCharModel(ped, defModel)
                    end
                end)
            end
        },
        {
            name = 'Mana Drain',
            icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'Прерываемая — поглощает магическую энергию цели, с каждой секундой передавая её ману владельцу способности.',
            callback = function()
                -- ability 2 callback
            end
        },
        {
            name = 'Finger of Death',
            icon = nil,
            mana_required = 250,
            cooldown = 100,
            tooltip = 'Разрывает вражеское существо, пытаясь вывернуть его наизнанку. Наносит большой урон, который увеличивается с каждым убитым этой способностью врагом.',
            callback = function()
                lua_thread.create(function()
                    local ped = nil
                    while not wasKeyPressed(1) do 
                        wait(0)
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        map.drawCircleIn3d(x, y, z, 4, 0xCC04ff00, 2)
                        ped = getNearestPedFromPos(movement.get_pointer_pos())
                    end
                    if not ped then return false end
                    if ped == PLAYER_PED then
                        sampAddChatMessage('error, no target for "Finger Of Death"', -1)
                        return false
                    end
                    if doesCharExist(ped) then
                        local isDead = map.set_hp(ped, getCharHealth(ped) - 400)
                    end
                end)
            end
        },
    }
}

HERO_OTCHETPUDGESWAT = {
    name = u8'Отчетик пудж сват',
    image = nil,
    model = 285,
    damage = 13,
    hit_distance = 3,
    hit_speed = 0.6,
    weapon = 28,
    weapon_ammo = 100,
    max_health = 500,
    max_mana = 380,
    hit_animation = {
        file = 'RIFLE',
        name = 'RIFLE_FIRE'
    },
    abilities = {
        {
            name = 'First',
             icon = nil,
            mana_required = 50,
            cooldown = 10,
            tooltip = 'FISRT',
            callback = function()
                -- ability 1 callback
            end
        },
        {
            name = 'Second',
             icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'SECOND',
            callback = function()
                -- ability 2 callback
            end
        },
        {
            name = 'The third',
             icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'SECOND',
            callback = function()
                -- ability 2 callback
            end
        },
        {
            name = 'Ultimate',
             icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'SECOND',
            callback = function()
                -- ability 2 callback
            end
        },
    }
}

HERO_PanSeek = {
    name = u8'PanSeek',
    image = nil,
    model = 169,
    damage = 13,
    hit_distance = 3,
    hit_speed = 0.6,
    weapon = 28,
    weapon_ammo = 100,
    max_health = 500,
    max_mana = 380,
    hit_animation = {
        file = 'RIFLE',
        name = 'RIFLE_FIRE'
    },
    abilities = {
        {
            type = MODULE_HERO.ABILITY_TYPE.PASSIVE,
            name = 'EkarniyBabay',
             icon = nil,
            mana_required = 50,
            cooldown = 10,
            tooltip = 'ПАССИВНАЯ\n\nВосстанавливает 1 единицу здоровья всем союзным существам, находящимся в радиусе 3 метров от вас каждую секундку',
            loop = function()
                if local_player.v.PanSeekPassiveHeal == nil then
                    local_player.v.PanSeekPassiveHeal = os.clock()
                end
                local x, y, z = getCharCoordinates(PLAYER_PED)
                map.drawCircleIn3d(x, y, z, 3, 0xCC04ff00, 2, 100) -- = function(x, y, z, radius, color, width, polygons) 
                    
                if local_player.v.PanSeekPassiveHeal + 1 - os.clock() < 0 then
                    for _, ped in ipairs(getAllChars()) do
                        if getCharModel(ped) == 105 then
                            if getDistanceBetweenCoords3d(x, y, z, getCharCoordinates(ped)) <= 3 then
                                map.set_hp(ped, getCharHealth(ped) + 1)
                                if getCharHealth(ped) > 300 then
                                    map.set_hp(ped, 300)
                                end
                            end
                        end
                    end
                    sampAddChatMessage('healded', -1)
                    local_player.v.PanSeekPassiveHeal = os.clock()
                end
            end
        },
        {
            name = 'Second',
            icon = nil,
            mana_required = 70,
            cooldown = 17,
            tooltip = 'Моментально восстанавливает 150 здоровья выбранному союзному существу',
            callback = function()
                lua_thread.create(function()
                    local point = createObject(19606, 0, 0, 0)
                    table.insert(map.pool.objects, point)
                    local pointer = movement.get_pointer_pos()
                    while not wasKeyPressed(1) do
                        wait(0)
                        map.drawCircleIn3d(x, y, z, 12, 0xCC04ff00, 2)
                        local data = movement.get_nearest_ped_from_pos()
                        if doesCharExist(data.handle) then
                            setObjectCoordinates(point, getCharCoordinates(data.handle))
                        end
                    end 
                    deleteObject(point)
                end)
            end
        },
        {
            name = 'The third',
             icon = nil,
            mana_required = 30,
            cooldown = 10,
            tooltip = 'SECOND',
            callback = function()
                -- нет
            end
        },
        {
            name = 'MEGA-HEAL',
             icon = nil,
            mana_required = 90,
            cooldown = 50,
            tooltip = 'Восстанавливает здоровье всех союзных существ на 75.',
            callback = function()
                lua_thread.create(function()
                    for _, ped in ipairs(getAllChars()) do
                        if getCharModel(ped) == 105 then
                            local pedX, pedY = convert3DCoordsToScreen(getCharCoordinates(ped))
                            renderDrawLine(selfX, selfY, pedX, pedY, 2, 0xCC49eb46)
                       
                            map.set_hp(ped, getCharHealth(ped) + 75)
                            if getCharHealth(ped) > 300 then
                                map.set_hp(ped, 300)
                            end
                        end
                    end
                    --[[
                    local start = os.clock()
                    while start + 10 - os.clock() > 0 do
                        wait(0)
                        local selfX, selfY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                        for _, ped in ipairs(getAllChars()) do
                            if getCharModel(ped) == 105 then
                                local pedX, pedY = convert3DCoordsToScreen(getCharCoordinates(ped))
                                renderDrawLine(selfX, selfY, pedX, pedY, 2, 0xCC49eb46)
                           
                                map.set_hp(ped, getCharHealth(ped) + 75)
                                if getCharHealth(ped) > 300 then
                                    map.set_hp(ped, 300)
                                end
                            end
                            --renderDrawLine(float pos1x, float pos1y, float pos2x, float pos2y, float width, uint color)
                        end
                    end
                    ]]
                end)
                -- ability 2 callback
            end
        },
    }
}

MODULE_HERO.list = {
    {
        name = 'Big Smoke',
        image = nil,
        model = 269,
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
                icon = nil,
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
                icon = nil,
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
            {
                name = 'PLACEHOLDER',
                icon = nil,
                mana_required = 30,
                cooldown = 10,
                tooltip = 'PLACEHOLDER',
                callback = function()
                    lua_thread.create(function()
                        
                    end)
                end
            }, 
            {
                name = 'PLACEHOLDER',
                icon = nil,
                mana_required = 30,
                cooldown = 10,
                tooltip = 'PLACEHOLDER',
                callback = function()
                    lua_thread.create(function()
                        
                    end)
                end
            }
        }
    },
    {
        name = 'Samp Funcs',
        image = nil,
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
                 icon = nil,
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
                 icon = nil,
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
                 icon = nil,
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
                 icon = nil,
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
        image = nil,
        model = 294,
        damage = 30,
        hit_distance = 14,
        hit_speed = 1,
        weapon = 34,
        weapon_ammo = 999,
        max_health = 580,
        max_mana = 255,
        hit_animation = {
            file = 'SILENCED',
            name = 'SILENCE_FIRE'
        },
        abilities = {
            {
                name = 'SHRAPNEL',
                 icon = nil,
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
                 icon = nil,
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
    HERO_OTCHETPUDGESWAT,
    HERO_PanSeek,
    HERO_LION
}

MODULE_HERO.loop = function()
    if local_player.PLAYER.hero then
        local abilities = local_player.PLAYER.hero.abilities
        for k, v in ipairs(abilities) do
            if v.type and v.type == MODULE_HERO.ABILITY_TYPE.PASSIVE then
                v.loop()
            end
        end
    end
end

MODULE_HERO.init = function()

end

return MODULE_HERO