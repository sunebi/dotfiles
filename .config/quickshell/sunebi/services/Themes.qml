pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs.services.cursor

// The color themes of the shell, one JSON file each in the themes directory. The chosen one is kept in the shell state directory, Colors reads its colors
Singleton {
  id: root

  // The island on the screen with the focus is open to the theme carousel while this is set
  property bool pickerOpen: false
  readonly property ListModel model: themes
  readonly property string current: storage.theme

  // The parsed files by theme id, which is the name of the file without .json
  property var definitions: ({})
  property var pending: []

  // The colors of a definition for the system color scheme. A theme that has one scheme only keeps it in both
  function tokensFor(definition: var): var {
    return (ColorScheme.dark ? (definition.dark ?? definition.light) : (definition.light ?? definition.dark)) ?? {};
  }

  function tokensOf(id: string): var {
    return tokensFor(definitions[id] ?? {});
  }

  function idAt(index: int): string {
    return index >= 0 && index < themes.count ? themes.get(index).themeId : "";
  }

  function nameAt(index: int): string {
    return index >= 0 && index < themes.count ? themes.get(index).name : "";
  }

  function indexOfCurrent(): int {
    for (let index = 0; index < themes.count; index++) {
      if (themes.get(index).themeId === current)
        return index;
    }
    return -1;
  }

  function refresh(): void {
    scanner.running = true;
  }

  function apply(id: string): void {
    storage.theme = id;
  }

  Component.onCompleted: refresh()

  ListModel {
    id: themes
  }

  // One line per file, the id, a tab and the JSON with its newlines removed
  Process {
    id: scanner

    command: ["sh", "-c", "for file in \"$1\"/*.json; do printf '%s\\t' \"$(basename \"$file\" .json)\"; tr -d '\\n' < \"$file\"; echo; done", "sh", Quickshell.shellPath("themes")]

    stdout: SplitParser {
      onRead: line => root.pending = [...root.pending, line]
    }

    onExited: {
      const found = {};
      for (const line of root.pending) {
        const separator = line.indexOf("\t");
        found[line.slice(0, separator)] = JSON.parse(line.slice(separator + 1));
      }
      root.pending = [];
      // The default theme first, the others by id
      const ids = Object.keys(found).sort((a, b) => a === "default" ? -1 : b === "default" ? 1 : a.localeCompare(b));
      root.definitions = found;
      // The same themes as before are left alone, a carousel that is open must not flicker
      if (ids.join("\n") === Array.from({
        length: themes.count
      }, (_, index) => themes.get(index).themeId).join("\n"))
        return;
      themes.clear();
      for (const id of ids)
        themes.append({
          themeId: id,
          name: found[id].name,
          filePath: Quickshell.shellPath("themes/" + id + ".json")
        });
    }
  }

  // Loaded before anything asks for a color, so the first frame is already in the chosen theme
  FileView {
    path: Quickshell.statePath("theme.json")
    blockLoading: true

    onAdapterUpdated: writeAdapter()
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound)
        writeAdapter();
    }

    adapter: JsonAdapter {
      id: storage

      property string theme: "default"
    }
  }

  IpcHandler {
    target: "theme"

    function toggle(): void {
      Wallpaper.pickerOpen = false;
      CursorTheme.pickerOpen = false;
      SessionMenu.open = false;
      root.refresh();
      root.pickerOpen = !root.pickerOpen && themes.count > 0;
    }
  }
}
