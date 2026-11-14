import QtQuick

import qs
import qs.components
import qs.services

// The glyphs are SF Symbols private use characters of SF Pro Text: cpu, memorychip and display (SF Symbols has no gpu symbol)
Capsule {
  // Equal to the vertical inset, so the first and last ring sit concentric with the round ends
  paddingX: (Theme.barHeight - Theme.resourceRingSize) / 2

  ResourceRing {
    glyph: "\u{100AE5}"
    value: ResourceUsage.cpu
    nudge: Qt.point(0.3, 0)
  }

  ResourceRing {
    glyph: "\u{100AE6}"
    value: ResourceUsage.memory
    nudge: Qt.point(0, -0.5)
  }

  // The stand pulls the box of the monitor down while its screen is what the eye centers
  ResourceRing {
    glyph: "\u{1008B9}"
    value: ResourceUsage.gpu
    nudge: Qt.point(0.3, 0.5)
  }
}
