pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick

import qs

Capsule {
  id: root

  required property HyprlandMonitor monitor

  Repeater {
    model: Config.workspaceCount

    delegate: Rectangle {
      id: button

      required property int index
      readonly property int workspaceId: index + 1
      readonly property bool active: root.monitor?.activeWorkspace?.id === workspaceId

      width: Theme.workspaceSize
      height: Theme.workspaceSize
      radius: width / 2
      color: active ? Theme.activeBackground : "transparent"

      Text {
        anchors.centerIn: parent
        text: button.workspaceId
        color: button.active ? Theme.foreground : Theme.mutedForeground
        font.family: Theme.fontText
        font.pixelSize: Theme.fontSize
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${button.workspaceId} })`)
      }
    }
  }
}
