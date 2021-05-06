hs.loadSpoon("Caffeine")
spoon.Caffeine:start()

--------------------------------------------------------------------------
-- Window Movement Bindings
--------------------------------------------------------------------------
hs.loadSpoon("WinWin")
winfocus = {'alt', 'ctrl'}
winmove = {'cmd', 'alt', 'ctrl'}

local resizebindings = {
	{key = 'H', position = 'halfleft',  focus = hs.window.filter.focusWest},
	{key = 'L', position = 'halfright', focus = hs.window.filter.focusEast},
	{key = 'K', position = 'halfup',    focus = hs.window.filter.focusNorth},
	{key = 'J', position = 'halfdown',  focus = hs.window.filter.focusSouth},
	{key = 'Y', position = 'cornerNW'},
	{key = 'O', position = 'cornerNE'},
	{key = 'N', position = 'cornerSW'},
	{key = '.', position = 'cornerSE'},
	{key = 'U', position = 'fullscreen'},
}

for _,v in ipairs(resizebindings) do
	hs.hotkey.bind(winmove, v.key, function()
		spoon.WinWin:moveAndResize(v.position)
	end)
	if v.focus then
		hs.hotkey.bind(winfocus, v.key, function()
            v.focus()
		end)
	end
end

-- TODO: Explore tweaking this
hs.hotkey.bind(winfocus, 'g', function()
    hs.grid.show()
end)

-- TOOD: can hammerspoon remember the previous location?
--[[hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'Z', function()
	spoon.WinWin:undo()
end)]]

--FIXME: update this to use hs.window.filter(?) and hs.window or something
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
--[[ move screens
--hs.hotkey.bind({'cmd', 'shift'}, 'H', function()
	--windows = hs.window.frontmostWindow():windowsToWest()
	--if windows[1] then
		--windows[1]:focus()
	--end
--end)
--hs.hotkey.bind({'cmd', 'shift'}, 'L', function()
	--windows = hs.window.frontmostWindow():windowsToEast()
	--if windows[1] then
		--windows[1]:focus()
	--end
--end)
--hs.hotkey.bind({'cmd', 'shift'}, 'K', function()
	--windows = hs.window.frontmostWindow():windowsToNorth()
	--if windows[1] then
		--windows[1]:focus()
	--end
--end)
--hs.hotkey.bind({'cmd', 'shift'}, 'J', function()
	--windows = hs.window.frontmostWindow():windowsToSouth()
	--if windows[1] then
		--windows[1]:focus()
	--end
--end)
--]]

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
