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
  implicitHeight: Math.max(Theme.barMarginTop + Theme.barHeight + Theme.barMarginTop + Theme.trayPopupHeight, Theme.barMarginTop + Math.max(Theme.islandPickerHeight, Theme.islandSessionHeight))
  exclusiveZone: Theme.barMarginTop + Theme.barHeight
  color: "transparent"
  // The keys of the wallpaper carousel and of the session menu need the keyboard, it is given back when they close
  WlrLayershell.keyboardFocus: dynamicIsland.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  // Only the capsules take input, the transparent gaps between them pass clicks through
  mask: Region {
    Region {
      item: resourceMonitor
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

  Workspaces {
    id: workspaces
    monitor: Hyprland.monitorFor(root.modelData)
    anchors.top: parent.top
    anchors.topMargin: Theme.barMarginTop
    anchors.left: parent.left
    anchors.leftMargin: Theme.barMarginX
  }

  ResourceMonitor {
    id: resourceMonitor
    anchors.top: parent.top
    anchors.topMargin: Theme.barMarginTop
    anchors.left: workspaces.right
    anchors.leftMargin: Theme.spacing
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
