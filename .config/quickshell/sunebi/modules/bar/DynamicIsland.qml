import QtQuick

import qs
import qs.services

Capsule {
  Text {
    text: DateTime.time
    color: Theme.foreground
    font.family: Theme.fontDisplay
    font.pixelSize: Theme.fontSize
  }
}
