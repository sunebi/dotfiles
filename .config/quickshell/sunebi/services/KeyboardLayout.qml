pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property var layouts: []
  property int activeIndex: 0

  readonly property bool multiple: layouts.length > 1
  readonly property string current: layouts[activeIndex] ?? ""

  Component.onCompleted: query.running = true

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (["activelayout", "configreloaded"].includes(event.name))
        query.running = true;
    }
  }

  // Only the main keyboard follows the layout switches, the other devices stay on their first layout
  Process {
    id: query
    command: ["hyprctl", "devices", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        const keyboards = JSON.parse(text).keyboards;
        const keyboard = keyboards.find(candidate => candidate.main) ?? keyboards[0];

        root.layouts = keyboard ? keyboard.layout.split(",") : [];
        root.activeIndex = keyboard?.active_layout_index ?? 0;
      }
    }
  }
}
