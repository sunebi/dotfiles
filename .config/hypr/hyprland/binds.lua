local keys = require("shared.keys")
local apps = require("shared.apps")

-- Flags
local locked = { locked = true }
local lockedRepeating = { locked = true, repeating = true }
local mouse = { mouse = true }

-- Settings
local volumeMax = 100 -- percent

local function bind(chords, action, opts)
  for _, chord in ipairs(type(chords) == "table" and chords or { chords }) do
    hl.bind(chord, action, opts)
  end
end

-- Launcher
bind(keys.launcher, hl.dsp.exec_cmd(apps.launcher))
bind(keys.clipboard, hl.dsp.exec_cmd(apps.clipboard))

-- Apps
bind(keys.terminal, hl.dsp.exec_cmd(apps.terminal))
bind(keys.fileManager, hl.dsp.exec_cmd(apps.fileManager))
bind(keys.browser, hl.dsp.exec_cmd(apps.browser))
bind(keys.editor, hl.dsp.exec_cmd(apps.editor))
bind(keys.volumeMixer, hl.dsp.exec_cmd(apps.volumeMixer))

-- Session
bind(keys.sessionMenu, hl.dsp.exec_cmd("qs -c sunebi ipc call session toggle"))
bind(
  keys.exit,
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Windows
bind(keys.closeWindow, hl.dsp.window.close())
bind(keys.toggleFloat, hl.dsp.window.float({ action = "toggle" }))
bind(keys.togglePseudo, hl.dsp.window.pseudo())
bind(keys.toggleSplit, hl.dsp.layout("togglesplit")) -- dwindle only

-- Window focus
bind(keys.focusLeft, hl.dsp.focus({ direction = "left" }))
bind(keys.focusRight, hl.dsp.focus({ direction = "right" }))
bind(keys.focusUp, hl.dsp.focus({ direction = "up" }))
bind(keys.focusDown, hl.dsp.focus({ direction = "down" }))

-- Window mouse
bind(keys.moveWindow, hl.dsp.window.drag(), mouse)
bind(keys.resizeWindow, hl.dsp.window.resize(), mouse)

-- Workspaces
-- The bar shows workspaces 1-9, and "r+1" has no upper bound, so stop at the last one
local firstWorkspace = 1
local lastWorkspace = 9

local function scrollWorkspace(step)
  return function()
    local target = hl.get_active_workspace().id + step
    if target < firstWorkspace or target > lastWorkspace then
      return
    end
    hl.dispatch(hl.dsp.focus({ workspace = step > 0 and "r+1" or "r-1" }))
  end
end

for i = firstWorkspace, lastWorkspace do
  bind(keys.workspaceFocus .. " + " .. i, hl.dsp.focus({ workspace = i }))
  bind(keys.workspaceMove .. " + " .. i, hl.dsp.window.move({ workspace = i }))
end

bind(keys.workspaceNext, scrollWorkspace(1))
bind(keys.workspacePrev, scrollWorkspace(-1))

-- Scratchpad
bind(keys.scratchpad, hl.dsp.workspace.toggle_special("magic"))

-- Utils
bind(keys.screenshot, hl.dsp.exec_cmd("hyprshot -m region -z"))
bind(keys.colorPicker, hl.dsp.exec_cmd(apps.colorPicker))
bind(keys.dictation, hl.dsp.exec_cmd(apps.dictation)) -- Handy cannot grab global keys on Wayland, so the compositor owns the key

-- Wallpaper
bind(keys.wallpaperPicker, hl.dsp.exec_cmd("qs -c sunebi ipc call wallpaper toggle"))
bind(keys.wallpaperRandom, hl.dsp.exec_cmd("qs -c sunebi ipc call wallpaper random"))

-- Theme
bind(keys.themePicker, hl.dsp.exec_cmd("qs -c sunebi ipc call theme toggle"))
bind(keys.themeToggle, hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-theme.sh"))

-- Brightness
bind(keys.brightnessUp, hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), lockedRepeating)
bind(keys.brightnessDown, hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), lockedRepeating)

-- Media
bind(keys.mediaToggle, hl.dsp.exec_cmd("qs -c sunebi ipc call media toggle"), locked)
bind(keys.mediaNext, hl.dsp.exec_cmd("qs -c sunebi ipc call media next"), locked)
bind(keys.mediaPrev, hl.dsp.exec_cmd("qs -c sunebi ipc call media previous"), locked)

-- Volume
bind(
  keys.volumeUp,
  hl.dsp.exec_cmd("wpctl set-volume -l " .. volumeMax / 100 .. " @DEFAULT_AUDIO_SINK@ 5%+"),
  lockedRepeating
)
bind(keys.volumeDown, hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), lockedRepeating)
bind(keys.volumeMute, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), lockedRepeating)
bind(keys.micMute, hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), lockedRepeating)
