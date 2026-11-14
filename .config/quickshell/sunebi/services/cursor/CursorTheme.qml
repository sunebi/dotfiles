pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs
import qs.services
import qs.services.themes
import qs.services.wallpaper

// The cursor theme of the user. The themes are found by xcursor_preview.py next to it, which also draws the arrow of each one for the picker, the chosen one is kept in the shell state directory and set again when the shell starts
Singleton {
  id: root

  // The island on the screen with the focus is open to the cursor carousel while this is set
  property bool pickerOpen: false
  readonly property ListModel model: themes
  readonly property string current: storage.theme

  property var pending: []

  function nameAt(index: int): string {
    return index >= 0 && index < themes.count ? themes.get(index).name : "";
  }

  function indexOfCurrent(): int {
    for (let index = 0; index < themes.count; index++) {
      if (themes.get(index).name === current)
        return index;
    }
    return -1;
  }

  function refresh(): void {
    scanner.running = true;
  }

  // Hyprland and XWayland take the theme at once, GTK apps get it from the settings, what reads only the environment has it after a restart
  function set(theme: string): void {
    Quickshell.execDetached(["sh", "-c", "hyprctl setcursor \"$1\" \"$2\"; gsettings set org.gnome.desktop.interface cursor-theme \"$1\"; gsettings set org.gnome.desktop.interface cursor-size \"$2\"", "sh", theme, String(Config.cursorSize)]);
  }

  function apply(theme: string): void {
    storage.theme = theme;
    set(theme);
  }

  Component.onCompleted: refresh()

  ListModel {
    id: themes
  }

  Process {
    id: scanner

    command: ["python3", "-I", Quickshell.shellPath("services/cursor/xcursor_preview.py"), Quickshell.cachePath("cursors")]

    stdout: SplitParser {
      onRead: line => root.pending = [...root.pending, line]
    }

    onExited: {
      const names = root.pending;
      root.pending = [];
      // The same themes as before are left alone, a carousel that is open must not flicker
      if (names.join("\n") === Array.from({
        length: themes.count
      }, (_, index) => themes.get(index).name).join("\n"))
        return;
      themes.clear();
      for (const name of names)
        themes.append({
          name: name,
          filePath: Quickshell.cachePath("cursors") + "/" + name + ".png"
        });
    }
  }

  FileView {
    path: Quickshell.statePath("cursor.json")

    onAdapterUpdated: writeAdapter()
    onLoaded: {
      if (storage.theme !== "")
        root.set(storage.theme);
    }
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound)
        writeAdapter();
    }

    adapter: JsonAdapter {
      id: storage

      property string theme: ""
    }
  }

  IpcHandler {
    target: "cursor"

    function toggle(): void {
      Wallpaper.pickerOpen = false;
      SessionMenu.open = false;
      Themes.pickerOpen = false;
      root.refresh();
      root.pickerOpen = !root.pickerOpen && themes.count > 0;
    }
  }
}
