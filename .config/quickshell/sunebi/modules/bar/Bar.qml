import Quickshell
import Quickshell.Hyprland
import QtQuick

import qs

PanelWindow {
  id: root

  required property var modelData

  screen: modelData
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: Theme.barMarginTop + Theme.barHeight
  color: "transparent"

  // Only the capsules take input, the transparent gaps between them pass clicks through
  mask: Region {
    Region {
      item: workspaces
    }
    Region {
      item: dynamicIsland
    }
    Region {
      item: systemTray
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

  DynamicIsland {
    id: dynamicIsland
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
