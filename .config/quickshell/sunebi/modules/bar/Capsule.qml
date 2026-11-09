import QtQuick

import qs

Rectangle {
  default property alias content: row.data

  implicitWidth: row.implicitWidth + 2 * Theme.capsulePaddingX
  implicitHeight: Theme.barHeight
  radius: height / 2
  color: Theme.background

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Theme.spacing
  }
}
