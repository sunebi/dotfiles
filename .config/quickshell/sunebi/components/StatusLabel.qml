import QtQuick

import qs

StyledText {
  // As tall as the icons it sits between, so the line is centered on them
  height: Theme.trayIconSize
  verticalAlignment: Text.AlignVCenter
  font.capitalization: Font.AllUppercase
  font.pixelSize: Theme.statusLabelFontSize
  font.weight: Theme.trayFontWeight
}
