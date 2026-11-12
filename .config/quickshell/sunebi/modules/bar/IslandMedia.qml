import Quickshell.Widgets
import QtQuick

import qs
import qs.services

Item {
  ClippingRectangle {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: height
    height: parent.height
    radius: Theme.radius / 2
    color: Theme.muted

    Image {
      anchors.fill: parent
      asynchronous: true
      fillMode: Image.PreserveAspectCrop
      mipmap: true
      source: Media.player?.trackArtUrl ?? ""
    }
  }

  Item {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: Config.visualizerBars * (Theme.visualizerBarWidth + Theme.visualizerBarSpacing) - Theme.visualizerBarSpacing
    height: Theme.trayIconSize

    Repeater {
      model: Config.visualizerBars

      delegate: Rectangle {
        required property int index

        x: index * (Theme.visualizerBarWidth + Theme.visualizerBarSpacing)
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.visualizerBarWidth
        height: Math.max(width, (AudioVisualizer.levels[index] ?? 0) * parent.height)
        radius: width / 2
        color: Theme.foreground

        // About one and a half frames of cava, enough to blend its steps into motion
        Behavior on height {
          NumberAnimation {
            duration: 1500 / Config.visualizerFramerate
          }
        }
      }
    }
  }
}
