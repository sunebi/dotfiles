import QtQuick

import qs.services

// Glyphs are SF Symbols private use code points of SF Pro Text: microphone.fill and microphone.slash.fill
StatusIcon {
  visible: Audio.hasMicrophone
  glyph: Audio.micMuted ? "\u{1002B3}" : "\u{1002B1}"

  onClicked: Audio.toggleMicMute()
}
