hs.loadSpoon("Caffeine")
spoon.Caffeine:start()

--[[
hs.window.highlight.ui.frameWidth = 5
hs.window.highlight.ui.frameColor = {0,0.6,1,0.5}
hs.window.highlight.ui.overlayColor = {0,0,0,0.05}
hs.window.highlight.ui.overlay = true
hs.window.highlight.start();
]]
--------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------
winfocus = {'alt', 'ctrl'}
winmove = {'cmd', 'alt', 'ctrl'}

hs.hotkey.bind(winfocus, 'r', function()
    hs.reload()
end)

--------------------------------------------------------------------------
-- Window Movement Bindings
--------------------------------------------------------------------------
local resizebindings = {
    -- Shift focus and snap focused window to half-screen positions
    {key = 'H', position = '[0,0,50,100]', focus = hs.window.filter.focusWest},
    {key = 'L', position = '[50,0,100,100]', focus = hs.window.filter.focusEast},
    --TODO instead of focusing north/south maybe use raise/sendToBack on the current screen/space?
    {key = 'K', position = '[0,0,100,50]',    focus = hs.window.filter.focusNorth},
    {key = 'J', position = '[0,50,100,100]',  focus = hs.window.filter.focusSouth},

    -- Resize focused window on grid
    {key = 'space', gridFunc = hs.grid.maximizeWindow},
    {key = '.', gridFunc = hs.grid.snap},
    {key = '=', gridFunc = hs.grid.resizeWindowWider},
    {key = '-', gridFunc = hs.grid.resizeWindowThinner},
    {key = '\\', gridFunc = hs.grid.resizeWindowTaller},
    {key = '\'', gridFunc = hs.grid.resizeWindowShorter},
    -- Move focused window on grid
    {key = 'Y', gridFunc = hs.grid.pushWindowLeft},
    {key = 'U', gridFunc = hs.grid.pushWindowDown},
    {key = 'I', gridFunc = hs.grid.pushWindowUp},
    {key = 'O', gridFunc = hs.grid.pushWindowRight},
}

for _,v in ipairs(resizebindings) do
    if v.position then
        hs.hotkey.bind(winmove, v.key, function()
            hs.alert(v.position)
            hs.window.focusedWindow():moveToUnit(v.position)
        end)
    end
    if v.focus then
        hs.hotkey.bind(winfocus, v.key, function()
            v.focus()
            centerMouse()
        end)
    end
    if v.gridFunc then
        hs.hotkey.bind(winfocus, v.key, function()
            v.gridFunc(hs.window.focusedWindow())
        end)
    end
end

--------------------------------------------------------------------------
-- Grid Settings
--------------------------------------------------------------------------
for _,screen in pairs(hs.screen.allScreens()) do
    if (string.find(screen:name(), 'Built.in Retina Display')) then
        -- Laptop display
        hs.grid.setGrid('2x2', screen)
    end
    if (string.find(screen:name(), 'UP2716D')) then
        -- 27" dell (QHD / 2k / WQHD / 2560x1440)
        --hs.grid.setGrid('3x2', screen)
        hs.grid.setGrid('6x2', screen)
    end
    if (string.find(screen:name(), 'U4021QW')) then
        -- 40" dell (5k2k / 5120x2160)
        hs.grid.setGrid('6x2', screen)
    end
end

--hs.grid.setGrid('2x2', hs.screen.find('Built.in Retina Display'))
--if (#hs.screen.allScreens() > 1) then
    ---- TODO: maybe instead of explicit screens, loop over screens and check sizes?
    --hs.grid.setGrid('3x2', hs.screen.find('DELL UP2716D'))
--end
--TODO use hs.screen.watcher to detect when a monitor is plugged in or removed
--and re-set the grid

--hs.grid.HINTS={
    --{'1','2','3','4','5'}, -- doesn't make sense on my kyria
    --{'6','7','8','9','0'}, -- doesn't make sense on my kyria
    --{'q','w','e','r','t'},
    --{'a','s','d','f','g'},
    --{'z','x','c','v','b'}
--}
hs.grid.HINTS={
    {'2','3','4'}, -- doesn't make sense on my kyria
    {'7','8','9'}, -- doesn't make sense on my kyria
    {'w','e','r'},
    {'s','d','f'},
    {'x','c','v'}
}
hs.hotkey.bind(winfocus, 'c', function()
    hs.grid.show()
end)

hs.hotkey.bind(winfocus, '/', function()
    -- First get the most recently-focused window on the next screen:
    local wf = hs.window.filter.new()
    local focusedWindow = hs.window.focusedWindow();
    local nextScreen = focusedWindow:screen():next()
    wf:setScreens(nextScreen:id())
    wf:setSortOrder(hs.window.filter.sortByFocusedLast)
    local nextWindow = wf:getWindows()[1]
    -- Then move focus and mouse:
    nextWindow:focus()
    centerMouse()
end)
--TODO: figure out key bindings for moving windows between screens
-- ehhhh...pushwindowleft/right seems to work.

function centerMouse()
    window = hs.window.focusedWindow()
    local windowMidpoint = hs.geometry.rectMidPoint(window:frame())
    hs.mouse.absolutePosition(windowMidpoint)
end

--------------------------------------------------------------------------
-- Focus Modal Bindings
--------------------------------------------------------------------------
focusMode = hs.hotkey.modal.new('cmd', 'e')
function focusMode:entered()
    -- TODO: How can I indicate this other than an "alert"?
end

function focusApp(appName)
    app = hs.application.find(appName)
    if not app then
        hs.alert(appName .. ' not open')
        focusMode:exit()
        return
    end
    window = app:focusedWindow()
    window:focus()
    focusMode:exit()
end

-- Individual applications
focusMode:bind('', 'D', function() focusApp('Discord') end)
focusMode:bind('', 'F', function() focusApp('Firefox') end)
focusMode:bind('', 'G', function() focusApp('Google Chrome') end)
focusMode:bind('', 'K', function() focusApp('Keybase') end)
focusMode:bind('', 'M', function() focusApp('Music') end)
focusMode:bind('', 'N', function() focusApp('Quiver') end)
focusMode:bind('', 'Q', function() focusApp('Quiver') end)
focusMode:bind('', 'S', function() focusApp('Slack') end)
focusMode:bind('', 'T', function() focusApp('iTerm2') end)
focusMode:bind('', 'V', function() focusApp('vivaldi') end)

-- Other Controls
focusMode:bind('', 'return', function()
    hs.window.focusedWindow():toggleFullScreen()
    focusMode:exit()
end)
focusMode:bind('', 'escape', function()
    hs.alert"Exit focus mode"
    focusMode:exit()
end)
