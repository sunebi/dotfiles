import QtQuick

import qs

MouseArea {
  id: root

  required property string glyph

  implicitWidth: label.implicitWidth
  implicitHeight: Theme.trayIconSize

  StyledText {
    id: label

    anchors.verticalCenter: parent.verticalCenter
    text: root.glyph
    font.weight: Theme.trayFontWeight
  }
}
