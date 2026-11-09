# Dotfiles

Personal Arch Linux desktop config on a two-monitor PC: Hyprland (Lua config) and a Quickshell (QML) shell named `sunebi`. The repo is meant to become public.

## Ground rules

- `~/.config/hypr` and `~/.config/quickshell` are symlinks into this repo. Edit files here only, never in the live directories.
- Keep personal data (emails, keys, `.gitconfig`, `.ssh`) out of tracked files. Files a tool generates per user, such as `.qmlls.ini`, are gitignored.
- Formatting is owned by `.editorconfig` (one global value, no per-language overrides) and `.config/quickshell/sunebi/.qmlformat.ini`. Run the formatter instead of tuning style by hand.
- One file, one responsibility. Comments explain why, not what.
- Commit only when asked, one commit per request, message `type(scope): subject`.
- The user writes Russian, so reply in Russian.

## Tools

- Hyprland 0.57 with a Lua config, Quickshell 0.3.2 on Qt 6.12.
- Use `/usr/lib/qt6/bin/qmlformat` and `/usr/lib/qt6/bin/qmllint`. The `qmlformat` in `PATH` is Qt 5 and ignores `.qmlformat.ini`.
- Verify by running the result and looking at it (`qs log -c sunebi`, `grim` screenshots, `hyprctl`), not by reading the code.

## Task docs

Read only the one that matches the task.

- [docs/quickshell.md](docs/quickshell.md): running and debugging the shell, where settings and theme live, QML conventions, lint noise.
- [docs/hyprland.md](docs/hyprland.md): Lua config layout, keybind conventions, look and monitor setup.
