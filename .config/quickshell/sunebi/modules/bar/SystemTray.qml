import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import qs
import qs.services

Capsule {
  Repeater {
    model: SystemTray.items

    delegate: IconImage {
      id: trayIcon

      required property SystemTrayItem modelData

      source: modelData.icon
      implicitSize: Theme.trayIconSize

      MouseArea {
        anchors.fill: parent

        // activate() on menu-only items can close the app
        onClicked: {
          if (!trayIcon.modelData.onlyMenu)
            trayIcon.modelData.activate();
        }
      }
    }
  }

  StyledText {
    visible: Bluetooth.connected
    text: "BT"
    color: Theme.mutedForeground
  }

  StyledText {
    text: `${Math.round(Audio.volume * 100)}%`
    color: Theme.mutedForeground
  }
}
