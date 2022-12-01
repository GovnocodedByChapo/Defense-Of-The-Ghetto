local ffi = require('ffi')
local imgui = require('mimgui')

local core = require('DOTG1.core')
local ui = core.ui
local net = core.net
local map = require('DOTG1.map')

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil

    ui.init()
end)

local ui_frame = imgui.OnFrame(
    function() 
        return ui.is_any_window_active()
    end,
    function(self)
        self.HideCursor = not select(2, ui.is_any_window_active())
        ui.draw_ui_here()
    end
)

addEventHandler('onReceiveRpc',     function() net.raknet_handler() end)
addEventHandler('onSendRpc',        function() net.raknet_handler() end)
addEventHandler('onReceivePacket',  function() net.raknet_handler() end)
addEventHandler('onSendPacket',     function() net.raknet_handler() end)

function main()
    while not isSampAvailable() do wait(0) end
    core.log('Started')
    core.log('Initializing core...')
    core.init()
    core.log('core.lua initialized!')
    wait(-1)
end
