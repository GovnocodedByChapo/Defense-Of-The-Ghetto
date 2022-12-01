MODULE = {
    __VERSION = 0.1,
    __AUTHOR = 'chapo',
    ai = require('DOTG1').ai,
    ui = require('DOTG1').ui,
    net = require('DOTG1').net,
    requested_models = {},
    log_file = getWorkingDirectory()..'\\DOTG1.log',
    SIDE = {
        GROOVE = 0,
        BALLAS = 1
    }
}

MODULE.log = function(...)
    local args = {...}
    for k, v in ipairs(args) do
        args[k] = tostring(v)
    end
    local LOG = io.open(MODULE.log_file, doesFileExist(MODULE.log_file) and 'a' or 'w')
    LOG:write(table.concat(args, '\t')..'\n')
    LOG:close()
end

MODULE.init = function()
    for k, v in ipairs(requested_models) do
        if not hasModelLoaded(v) then
            requestModel(v)
            loadAllModelsNow()
        end
    end
end

MODULE.open_main_menu = function()

end

return MODULE