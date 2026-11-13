# Hyprland config (`.config/hypr`)

## Layout

- `hyprland.lua` only holds the ordered `require("hyprland.*")` calls. Modules live in `hyprland/`, one per Hyprland wiki section.
- `shared/keys.lua` holds the key chords and `shared/apps.lua` the applications, both used by `hyprland/binds.lua`. Binds are grouped into named blocks (Launcher, Apps, Session, Windows, Workspaces, Utils, Wallpaper, Brightness, Media, Volume).
- Media keys and wallpaper binds call the shell through `qs -c sunebi ipc call <target> <function>` (`media`: `toggle`, `next`, `previous`; `wallpaper`: `toggle`, `random`; `session`: `toggle`, on `CTRL + ALT + Delete`), so there is no `playerctl` dependency. They only work while the shell runs.

## Conventions

- Dispatchers use Lua syntax in 0.57: `hl.dsp.focus({ workspace = 3 })`, not the old string form.
- Single space around `=`, no column alignment.
- Only 9 workspaces (1-9). There is no key for a tenth, and the bar shows nine.
- Keybinds are the user's own. Take code style from caelestia, never its shortcuts.

## Look and hardware

- No window borders, no dimming of inactive windows (macOS-like).
- Monitors: DP-2 at 0x0 and DP-1 at 1920x0, both 1920x1080 at 100 Hz. Explicit mode and position are required, defaults give 60 Hz and an unstable order.
- It is a desktop PC, so laptop settings such as touchpad are optional.
