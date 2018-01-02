hs.loadSpoon("Caffeine")
spoon.Caffeine:start()

--------------------------------------------------------------------------
-- Window Movement Bindings
--------------------------------------------------------------------------
hs.loadSpoon("WinWin")
local resizebindings = {
	{key = 'H', position = 'halfleft',  screen = 'left'},
	{key = 'L', position = 'halfright', screen = 'right'},
	{key = 'K', position = 'halfup'},
	{key = 'J', position = 'halfdown'},
	{key = 'Y', position = 'cornerNW'},
	{key = 'O', position = 'cornerNE'},
	{key = 'N', position = 'cornerSW'},
	{key = '.', position = 'cornerSE'},
	{key = 'U', position = 'fullscreen'},
}
for _,v in ipairs(resizebindings) do
	hs.hotkey.bind({'cmd', 'ctrl'}, v.key, function()
		spoon.WinWin:moveAndResize(v.position)
	end)
	if v.screen then
		hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, v.key, function()
			spoon.WinWin:moveToScreen(v.screen)
		end)
	end
end

hs.hotkey.bind({'cmd', 'ctrl'}, 'Z', function()
	spoon.WinWin:undo()
end)

--------------------------------------------------------------------------
-- Focus Modal Bindings
--------------------------------------------------------------------------
focusMode = hs.hotkey.modal.new('cmd', 'e')
function focusMode:entered()
	-- Can I change the hammerspoon dock icon instead of alerting
	--hs.alert'Focus hotkeys'
end
--[[
function focusmode:exited()
	hs.alert'exited mode'
end
]]

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

function focusScreen(direction)
	curScreen = hs.screen.mainScreen()
end

-- Individual applications
focusMode:bind('', 'T', function() focusApp('iTerm2') end)
focusMode:bind('', 'G', function() focusApp('Google Chrome') end)
focusMode:bind('', 'M', function() focusApp('iTunes') end)
focusMode:bind('', 'S', function() focusApp('Slack') end)
focusMode:bind('', 'N', function() focusApp('Quiver') end)
focusMode:bind('', 'Q', function() focusApp('Quiver') end)

-- Other Controls
focusMode:bind('', 'return', function()
	hs.window.focusedWindow():toggleFullScreen()
	focusMode:exit()
end)
focusMode:bind('', 'escape', function()
	hs.alert"Exit focus mode"
	focusMode:exit()
end)

hs.hotkey.bind({'cmd', 'shift'}, 'H', function()
	windows = hs.window.frontmostWindow():windowsToWest()
	if windows[1] then
		windows[1]:focus()
	end
end)
hs.hotkey.bind({'cmd', 'shift'}, 'L', function()
	windows = hs.window.frontmostWindow():windowsToEast()
	if windows[1] then
		windows[1]:focus()
	end
end)
hs.hotkey.bind({'cmd', 'shift'}, 'K', function()
	windows = hs.window.frontmostWindow():windowsToNorth()
	if windows[1] then
		windows[1]:focus()
	end
end)
hs.hotkey.bind({'cmd', 'shift'}, 'J', function()
	windows = hs.window.frontmostWindow():windowsToSouth()
	if windows[1] then
		windows[1]:focus()
	end
end)

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

hs.hotkey.bind('alt', '§', function()
	focusScreen(hs.window.focusedWindow():screen():next())
end)
hs.hotkey.bind('alt', '\\', function()
	focusScreen(hs.window.focusedWindow():screen():next())
end)

