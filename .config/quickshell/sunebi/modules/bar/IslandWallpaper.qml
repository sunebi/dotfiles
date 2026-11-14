import Quickshell.Widgets
import QtQuick

import qs
import qs.services

Item {
  ClippingRectangle {
    id: preview

    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: Math.round(height * 16 / 9)
    height: parent.height
    radius: Theme.radius / 2
    color: Colors.muted

    CoverArt {
      anchors.fill: parent
      source: Wallpaper.current !== "" ? "file://" + Wallpaper.current : ""
    }
  }

  StyledText {
    anchors.left: preview.right
    anchors.leftMargin: Theme.spacing
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    elide: Text.ElideRight
    text: Wallpaper.name
    font.weight: Theme.trayFontWeight
  }
}
