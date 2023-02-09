local imgui = require('mimgui')
RESOURCE = {
    TEXTURES_LOADED = false,
    path = getWorkingDirectory()..'\\lib\\DOTG1\\resource',
    item_icon = {
        ['Enchanted Mango'] = '',
        ['blink_dagger'] = '',
        ['Faerie Fire'] = '',
    },
    placeholder = '',
    logo = ''
}

RESOURCE.hero_icon = {}
local hero = require('DOTG1.hero')
local items = require('DOTG1.items')

function RESOURCE.load_heroes() 
    if not TEXTURES_LOADED then
        TEXTURES_LOADED = true
        local status, mainContent = pcall(require, 'lib.DOTG1.resource.maincontent')
        if status then
            RESOURCE.placeholder = loadImageFromBase85(mainContent.placeholder)
            RESOURCE.logo = loadImageFromBase85(mainContent.logo)
        end

        -->> load heroes icons
        for heroIndex, heroData in ipairs(hero.list) do
            local status, data = pcall(require, 'lib.DOTG1.resource.hero.'..heroIndex)
            if data then
                hero.list[heroIndex].image = loadImageFromBase85(data.player) or RESOURCE.placeholder
                for abilityIndex, abilityData in ipairs(heroData.abilities) do
                    if data.abilities and data.abilities[abilityIndex] then
                        hero.list[heroIndex].abilities[abilityIndex].image = loadImageFromBase85(data.abilities[abilityIndex])    
                        print(type(hero.list[heroIndex].abilities.image)) 
                    else
                        print(heroIndex, abilityIndex, 'data.abilities[abilityIndex] == nil', data.abilities[abilityIndex] == nil)           
                    end
                end
            else
                print('[ERROR][RESOURCE] Cannot load images for hero, ', heroIndex, 'data is nil', data)
            end
        end

        -->> load items icons
        local status, itemsIcons = pcall(require, 'lib.DOTG1.resource.items')
        if status then
            for itemIndex, itemData in pairs(items.list) do 
                if itemsIcons[itemIndex] then
                    items.list[itemIndex].icon = loadImageFromBase85(itemsIcons[itemIndex])
                end
            end
        end
    end
        
        --[[
        assert(doesDirectoryExist(RESOURCE.path), 'no res path')
        assert(doesFileExist(RESOURCE.path..'\\placeholder.png'), 'no placeholder.png')
        assert(doesFileExist(RESOURCE.path..'\\logo.png'), 'no logo.png')
        
        RESOURCE.placeholder = imgui.CreateTextureFromFile(RESOURCE.path..'\\placeholder.png')
        RESOURCE.logo = imgui.CreateTextureFromFile(RESOURCE.path..'\\logo.png')
        
        for index, heroData in ipairs(hero.list) do
            local data = RESOURCE.path..'\\hero\\'..index..'\\data.lua'
            if doesFileExist(data) then
                local this = import(data)
                hero.list[index].image = this.player and imgui.CreateTextureFromFileInMemory(imgui.new('const char*', this.player), #this.player) or RESOURCE.placeholder
                for abilityIndex = 1, #hero.list[index].abilities do
                    if this.abilities[abilityIndex] then
                        print('loaded ability icon with index ', abilityIndex)
                        hero.list[index].abilities[abilityIndex].image = imgui.CreateTextureFromFileInMemory(imgui.new('const char*', this.abilities[abilityIndex]), #this.abilities[abilityIndex])
                    end
                end
            end
        end
        ]]
end

function loadImageFromBase85(data)
    return imgui.CreateTextureFromFileInMemory(imgui.new('const char*', data), #data)
end

return RESOURCE