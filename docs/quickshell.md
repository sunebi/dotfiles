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
- `modules/bar/`: bar components (`Bar`, `Workspaces`, `DynamicIsland`, `SystemTray`, `Capsule`, `StyledText`).

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
