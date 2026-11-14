pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

// The system color scheme, the one hypr/scripts/toggle-theme.sh flips. `monitor` only prints changes, so `get` gives the value at start
Singleton {
  id: root

  property bool dark: true

  Process {
    running: true
    command: ["sh", "-c", "gsettings get org.gnome.desktop.interface color-scheme; exec gsettings monitor org.gnome.desktop.interface color-scheme"]

    stdout: SplitParser {
      onRead: line => root.dark = line.includes("prefer-dark")
    }
  }
}
