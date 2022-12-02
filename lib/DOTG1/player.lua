--[[
    player_pool_struct = {
        name = 'name',
        hero = 0,
    }
]]

MODULE = {
    player_pool = {},
}

MODULE.add_to_pool = function(id, params)

end

MODULE.get_player = function(id)
    return MODULE.player_pool[id]
end

return MODULE