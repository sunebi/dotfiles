# Hyprland config (`.config/hypr`)

## Layout

- `hyprland.lua` only holds the ordered `require("hyprland.*")` calls. Modules live in `hyprland/`, one per Hyprland wiki section.
- `shared/keys.lua` holds the key chords and `shared/apps.lua` the applications, both used by `hyprland/binds.lua`. Binds are grouped into named blocks (Launcher, Apps, Session, Windows, Workspaces, Utils, Wallpaper, Brightness, Media, Volume).
- Media keys and wallpaper binds call the shell through `qs -c sunebi ipc call <target> <function>` (`media`: `toggle`, `next`, `previous`; `wallpaper`: `toggle`, on `SUPER + CTRL + W`; `session`: `toggle`, on `CTRL + ALT + Delete`; `theme`: `toggle`, on `SUPER + CTRL + T`), so there is no `playerctl` dependency. They only work while the shell runs.

The light/dark switch is `scripts/toggle-theme.sh` on `SUPER + CTRL + SHIFT + D`. It flips `color-scheme` and `gtk-theme` in gsettings (stored in dconf, outside the repo), so a fresh machine starts light until it runs once. `QT_QPA_PLATFORMTHEME` is deliberately unset so Qt follows the portal's color scheme.

## Conventions

- Dispatchers use Lua syntax in 0.57: `hl.dsp.focus({ workspace = 3 })`, not the old string form.
- Single space around `=`, no column alignment.
- Only 9 workspaces (1-9). There is no key for a tenth, and the bar shows nine.
- Keybinds are the user's own. Take code style from caelestia, never its shortcuts.

## Look and hardware

- No window borders, no dimming of inactive windows (macOS-like).
- Monitors: DP-2 at 0x0 and DP-1 at 1920x0, both 1920x1080 at 100 Hz. Explicit mode and position are required, defaults give 60 Hz and an unstable order.
- The cursor theme is set by `XCURSOR_THEME` and `HYPRCURSOR_THEME` in `env.lua`, read when Hyprland starts. There is no switcher, change the name there.
- It is a desktop PC, so laptop settings such as touchpad are optional.
