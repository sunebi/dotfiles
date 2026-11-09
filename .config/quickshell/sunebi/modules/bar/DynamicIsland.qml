import QtQuick

import qs
import qs.services

Capsule {
  StyledText {
    text: DateTime.time
    font.family: Theme.fontDisplay
  }
}
