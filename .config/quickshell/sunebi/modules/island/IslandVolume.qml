import QtQuick

import qs
import qs.components
import qs.services

Item {
  StyledText {
    id: glyph

    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: Theme.volumeIconWidth
    horizontalAlignment: Text.AlignHCenter
    opacity: Audio.muted ? 0.5 : 1
    text: Audio.volumeGlyph
    font.weight: Theme.trayFontWeight
  }

  Rectangle {
    anchors.left: glyph.right
    anchors.leftMargin: Theme.spacing
    anchors.right: parent.right
    // The glyph's own side bearing makes its edge look further from the pill than the track's, this evens the two out
    anchors.rightMargin: Theme.spacing / 2
    anchors.verticalCenter: parent.verticalCenter
    height: Theme.islandTrackHeight
    radius: height / 2
    opacity: Audio.muted ? 0.5 : 1
    color: Colors.muted

    Rectangle {
      // The ratio is animated and not the width, so the fill follows the track while the island widens instead of growing from zero
      property real shown: Math.min(1, Audio.volume / Config.volumeMax)

      width: parent.width * shown
      height: parent.height
      radius: height / 2
      color: Colors.primary

      Behavior on shown {
        NumberAnimation {
          duration: Theme.indicatorDuration / 2
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
