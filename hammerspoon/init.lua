hs.loadSpoon("Caffeine")
spoon.Caffeine:start()

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
            --TODO: maybe also center cursor in new window?
            -- Or instead, flash the frame, if I can do that?
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
-- Use a 2x2 grid on the built-in display but a 3x2 grid on the external
hs.grid.setGrid('2x2', hs.screen.primaryScreen())
if (#hs.screen.allScreens() > 1) then
    -- TODO: maybe instead of explicit screens, loop over screens and check sizes?
    hs.grid.setGrid('3x2', hs.screen.primaryScreen():next())
end
hs.grid.HINTS={
    {'f9', 'f10', 'f12'}, -- doesn't make sense on my kyria
    {'2', '3', '4'},      --doesn't make sense on my kyria
    {'w','e','r'},
    {'s','d','f'},
    {'x','c','v'}
}
hs.hotkey.bind(winfocus, 'c', function()
    hs.grid.show()
end)

--FIXME: update this to use hs.window.filter(?) and hs.window or something
--FIXME: center mouse in focused window, not the whole screen
-- example code for focusing the next screen:
-- https://github.com/Hammerspoon/hammerspoon/issues/835
function focusScreen(screen)
	local windows = hs.fnutils.filter(
		hs.window.orderedWindows(),
		hs.fnutils.partial(isInScreen, screen))
	local windowToFocus = #windows > 0 and windows[1] or hs.window.desktop()
	windowToFocus:focus()
	local pt = hs.geometry.rectMidPoint(screen:fullFrame())
	hs.mouse.setAbsolutePosition(pt)
end
function isInScreen(screen, win)
	return win:screen() == screen
end

hs.hotkey.bind(winfocus, '/', function()
    screen = hs.screen.mainScreen():next()
	focusScreen(screen)
end)

--TODO: figure out key bindings for moving windows between screens
-- ehhhh...pushwindowleft/right seems to work.

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
