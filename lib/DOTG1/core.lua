local ffi = require('ffi')
_G['SIDE_GROOVE'], _G['SIDE_BALLAS'], _G['GAME_STATE'] = 0, 1, { NONE = 0, MAIN_MENU = 1, HERO_SELECT = 2, IN_GAME = 3, IN_GAME_PAUSED = 4 }
_G['assertfunc'] = function(condition, text, callback)
    if not condition then
        callback()
        assert(condition, text)
    end
end
_G['_require'] = _G['require']
_G['require'] = function(module, URL)
    local status, result = pcall(_require, module)
    if not status then
        ffi.cdef([[int MessageBoxA(void* hWnd, const char* lpText, const char* lpCaption, unsigned int uType);]])
        local btn = ffi.C.MessageBoxA(ffi.cast('void*', readMemory(0x00C8CF88, 4, false)), ('Ошибка, модуль "%s" не найден!\n\n%s\n\n'..(URL and '\nОткрыть страницу загрузки?' or '')):format(module, result), thisScript().name..' - error', URL and 0x4 or 0x0)
        if URL and btn == 6 then os.execute(('explorer "%s"'):format(URL)) end
        assert(status, result)
    end
    return result
end

MODULE = {
    __VERSION = 0.1,
    __AUTHOR = 'chapo',
    log_file = getWorkingDirectory()..'\\DOTG1.log',
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

return MODULE