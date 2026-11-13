pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import QtQuick

import qs

Singleton {
  id: root

  // Path of the wallpaper on the screens, empty until the first change or until awww tells which one it restored
  property string current: ""
  readonly property string name: current.split("/").pop().replace(/\.[^.]+$/, "")

  // The picker window of the screen with the focus shows while this is set
  property bool pickerOpen: false
  readonly property FolderListModel model: files

  // Emitted when the user changes the wallpaper, not when the shell starts
  signal applied

  function pathAt(index: int): string {
    return files.get(index, "filePath");
  }

  function indexOfCurrent(): int {
    for (let index = 0; index < files.count; index++) {
      if (pathAt(index) === current)
        return index;
    }
    return -1;
  }

  function nameAt(index: int): string {
    return files.get(index, "fileName") ?? "";
  }

  function apply(path: string): void {
    current = path;
    Quickshell.execDetached(["awww", "img", "--transition-type", "fade", path]);
    applied();
  }

  // Never the wallpaper that is already shown, unless it is the only one
  function random(): void {
    if (files.count === 0)
      return;
    let index = 0;
    if (files.count > 1) {
      do
        index = Math.floor(Math.random() * files.count);
      while (pathAt(index) === current)
    }
    apply(pathAt(index));
  }

  FolderListModel {
    id: files

    folder: "file://" + Config.wallpaperDir
    nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp"]
    caseSensitive: false
    showDirs: false
  }

  Process {
    running: true
    command: ["awww", "query"]

    stdout: SplitParser {
      onRead: line => {
        const match = line.match(/image: (.+)$/);
        if (match && root.current === "")
          root.current = match[1];
      }
    }
  }

  IpcHandler {
    target: "wallpaper"

    function toggle(): void {
      SessionMenu.open = false;
      CursorTheme.pickerOpen = false;
      root.pickerOpen = !root.pickerOpen && files.count > 0;
    }

    function random(): void {
      root.random();
    }
  }
}
