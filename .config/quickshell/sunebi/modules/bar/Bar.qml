import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

import qs
import qs.services

PanelWindow {
  id: root

  required property var modelData

  screen: modelData
  anchors {
    top: true
    left: true
    right: true
  }
  // Tall enough for the tray overflow popup, which is drawn inside this window to allow dragging icons into and out of it
  implicitHeight: Math.max(Theme.barMarginTop + Theme.barHeight + Theme.barMarginTop + Theme.trayPopupHeight, Theme.barMarginTop + Theme.islandPickerHeight)
  exclusiveZone: Theme.barMarginTop + Theme.barHeight
  color: "transparent"
  // The arrow keys of the wallpaper carousel need the keyboard, it is given back when the carousel closes
  WlrLayershell.keyboardFocus: dynamicIsland.pickerVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  // Only the capsules take input, the transparent gaps between them pass clicks through
  mask: Region {
    // While the carousel is open, a click anywhere in the window outside of it closes it
    Region {
      width: dynamicIsland.pickerVisible ? root.width : 0
      height: dynamicIsland.pickerVisible ? root.height : 0
    }
    Region {
      item: workspaces
    }
    Region {
      item: dynamicIsland
    }
    Region {
      item: systemTray
    }
    Region {
      item: systemTray.overflowPopup
    }
  }

  MouseArea {
    anchors.fill: parent
    enabled: dynamicIsland.pickerVisible
    onClicked: Wallpaper.pickerOpen = false
  }

  Workspaces {
    id: workspaces
    monitor: Hyprland.monitorFor(root.modelData)
    anchors.top: parent.top
    anchors.topMargin: Theme.barMarginTop
    anchors.left: parent.left
    anchors.leftMargin: Theme.barMarginX
  }

  DynamicIsland {
    id: dynamicIsland
    monitor: Hyprland.monitorFor(root.modelData)
    anchors.top: parent.top
    anchors.topMargin: Theme.barMarginTop
    anchors.horizontalCenter: parent.horizontalCenter
  }

  SystemTray {
    id: systemTray
    anchors.top: parent.top
    anchors.topMargin: Theme.barMarginTop
    anchors.right: parent.right
    anchors.rightMargin: Theme.barMarginX
  }
}
