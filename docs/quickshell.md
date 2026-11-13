# Quickshell shell (`.config/quickshell/sunebi`)

## Run and debug

- Start with `qs -c sunebi`, logs with `qs log -c sunebi`, running instances with `qs list --all`. Hyprland autostart also launches it.
- After swapping the config directory, an already running `qs` keeps the old code in memory. Stop the old instance before judging a change.
- Hot reload sometimes fails on a just-created file (`X is not a type`, `module ... is not installed`). `touch shell.qml` retries it.
- After many hot reloads the Hyprland socket can drop (`PeerClosedError`) and workspace state freezes. Restart `qs` completely.

## Where things live

- `Config.qml`: behavior settings (volume steps, date formats, workspace count, dark theme switch). Not colors or sizes.
- `Theme.qml`: colors (shadcn neutral tokens, light or dark by `Config.darkTheme`), bar sizes, fonts.
- `services/`: singletons. A skeleton inherited from end-4/dots-hyprland with the hearing protection removed. Check usage before deleting anything.
- `modules/bar/`: bar components (`Bar`, `Workspaces`, `DynamicIsland` with `IslandMedia` and `IslandVolume`, `SystemTray`, `TrayItem`, `StatusLabel`, `Capsule`, `StyledText`).
- Dynamic Island: always a pill that widens with its content (`Theme.islandIdleWidth`, `islandMediaWidth`, `islandVolumeWidth`), empty while idle. It shows the cover and six `cava` levels of the playing player, or the volume bar for a moment after it changes. `services/Media.qml` picks the player (`Config.mediaPlayerPriority`, then the one that started last), `services/AudioVisualizer.qml` runs `cava` (it must be installed) on that app's PipeWire stream, so other apps do not move the bars. The date and time live in the tray.
- Wallpaper: `services/Wallpaper.qml` lists `Config.wallpaperDir` (`~/Pictures/Wallpapers`, name order) and sets the image with `awww img` (the `awww-daemon` from Hyprland autostart restores the last one after a restart). `SUPER+CTRL+T` shows the next wallpaper, `SUPER+CTRL+ALT+T` a random one, and the island shows `IslandWallpaper` (preview and name) for `Config.wallpaperHudMs`. `CoverArt` keeps the previous picture until the next has loaded, a big PNG can take a moment.
- Tray overflow: items not pinned live in a popup drawn inside the bar window (a `PopupWindow` cannot receive a dragged icon), so `Bar` is taller than its `exclusiveZone`. Drag a bar icon onto the chevron to hide it (the chevron also appears during a drag when nothing is hidden yet), drag a popup icon into the bar to pin it, or drop an icon onto another icon of the same place to swap them. Apps seen for the first time start hidden. The choice and order are saved by `services/TrayPins.qml` in `~/.local/state/quickshell/by-shell/<id>/tray.json`, keyed by the item `id` from `SystemTrayItem`.

## Conventions

- Imports: external block first (`Quickshell`, then `Quickshell.*`, then `QtQuick`), a blank line, then internal (`qs`, then `qs.*`).
- All bar text goes through `StyledText`: native rendering follows fontconfig, Qt's own rasterizer adds color fringes.
- Fonts are SF Pro Text and SF Pro Display, icons come from SF Pro Text. Capsules have no outline.
- Names follow https://tum-esi.github.io/common-coding-conventions: no abbreviations, no generic names.

## Checks

- Format: `/usr/lib/qt6/bin/qmlformat <file>` must print the file unchanged. VSCode formats qml on save.
- `qmllint` noise that code cannot fix: `Type X not declared as singleton in qmldir` (a real `qmldir` does not help), `PanelWindow is not creatable`, `Member "values" not found on UntypedObjectModel`.
- Screenshots: `grim -g "x,y WxH"` uses global coordinates. DP-2 starts at 0,0 and DP-1 at 1920,0.
- No input emulation tool is installed. `hyprctl dispatch 'hl.dsp.cursor.move({ x = .., y = .. })'` moves the cursor but delivers hover events unreliably, so click and wheel need a manual check.
