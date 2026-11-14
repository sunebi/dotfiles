import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

import qs
import qs.services
import qs.services.cursor

// While the wallpaper carousel, the cursor carousel, the theme carousel or the session menu is open this transparent window covers the whole screen, so a click anywhere outside of the island closes the menu whatever is under the pointer. The hole in its mask leaves the island itself to the bar below. The window exists only while a menu is open, so nothing stays blocked after it closes
PanelWindow {
  id: root

  required property var modelData

  // The menu opens on the screen with the focus only, the other screens have no island to leave free
  readonly property bool hasIsland: Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor
  readonly property real holeWidth: !hasIsland ? 0 : SessionMenu.open ? Theme.islandSessionWidth : Theme.islandPickerWidth
  readonly property real holeHeight: !hasIsland ? 0 : SessionMenu.open ? Theme.islandSessionHeight : Theme.islandPickerHeight

  screen: modelData
  visible: Wallpaper.pickerOpen || CursorTheme.pickerOpen || Themes.pickerOpen || SessionMenu.open
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  WlrLayershell.namespace: "sunebi-dismiss"

  mask: Region {
    width: root.width
    height: root.height

    Region {
      x: (root.width - root.holeWidth) / 2
      y: Theme.barMarginTop
      width: root.holeWidth
      height: root.holeHeight
      intersection: Intersection.Subtract
    }
  }

  MouseArea {
    anchors.fill: parent
    onPressed: {
      SessionMenu.open = false;
      Wallpaper.pickerOpen = false;
      CursorTheme.pickerOpen = false;
      Themes.pickerOpen = false;
    }
  }
}
