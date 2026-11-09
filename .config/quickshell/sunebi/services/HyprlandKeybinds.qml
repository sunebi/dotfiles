pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

// Categories are the "Group" prefixes of "Group: description" bind descriptions in `hyprctl binds -j`
Singleton {
  id: root

  property var keybinds: []
  property var keybindCategories: []

  function categoriesOf(keybindList) {
    const categories = new Set();
    for (const keybind of keybindList) {
      const separatorIndex = keybind.description.indexOf(":");
      if (separatorIndex > 0)
        categories.add(keybind.description.substring(0, separatorIndex));
    }
    return Array.from(categories);
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "configreloaded")
        getKeybinds.running = true;
    }
  }

  Process {
    id: getKeybinds
    running: true
    command: ["hyprctl", "binds", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.keybinds = JSON.parse(text);
          root.keybindCategories = root.categoriesOf(root.keybinds);
        } catch (error) {
          console.error("[HyprlandKeybinds] Failed to parse keybinds:", error);
        }
      }
    }
  }
}
