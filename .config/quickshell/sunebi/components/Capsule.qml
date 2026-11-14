import QtQuick

import qs

Rectangle {
  default property alias content: row.data
  property int paddingX: Theme.capsulePaddingX

  implicitWidth: row.implicitWidth + 2 * paddingX
  implicitHeight: Theme.barHeight
  radius: height / 2
  color: Colors.background

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Theme.spacing
  }
}
