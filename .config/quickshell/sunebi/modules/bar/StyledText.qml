import QtQuick

import qs

Text {
  color: Theme.foreground
  font.family: Theme.fontText
  font.pixelSize: Theme.fontSize

  // Qt's own rasterizer adds color fringes, native rendering follows the fontconfig hinting instead
  renderType: Text.NativeRendering
}
