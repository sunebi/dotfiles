import QtQuick

import qs
import qs.services

// Glyphs are SF Symbols private use code points of SF Pro Text: speaker.slash.fill, speaker.fill and speaker.wave.1, 2 and 3.fill
StatusIcon {
  // Left aligned at the widest glyph width, so the speaker stays put while the waves come and go
  implicitWidth: Theme.volumeIconWidth
  glyph: {
    if (Audio.muted)
      return "\u{1002A3}";
    if (Audio.volume <= 0)
      return "\u{1002A1}";
    if (Audio.volume < Config.lowVolumeThreshold)
      return "\u{1002A5}";
    if (Audio.volume < Config.highVolumeThreshold)
      return "\u{1002A7}";
    return "\u{1002A9}";
  }

  onClicked: Audio.toggleMute()
  onWheel: wheel => {
    if (wheel.angleDelta.y > 0)
      Audio.incrementVolume();
    else if (wheel.angleDelta.y < 0)
      Audio.decrementVolume();
  }
}
