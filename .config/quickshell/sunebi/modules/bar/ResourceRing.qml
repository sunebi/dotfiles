import QtQuick
import QtQuick.Shapes

import qs

// A ring that fills clockwise from the top with the load, the symbol of the resource sits inside. The fill is primary and the symbol gray until the load is high, then both are red
Item {
  id: root

  required property string glyph
  required property real value
  // Optical correction of the symbol: its ink is not symmetric, so the centre of its box is not where the eye puts the centre
  property point nudge: Qt.point(0, 0)

  readonly property bool high: value >= Config.resourceHighLoad
  // Not readonly, a Behavior cannot animate a read-only property
  property color tint: high ? Theme.destructive : Theme.mutedForeground
  property color fillTint: high ? Theme.destructive : Theme.primary
  // Follows the sample on a spring so the ring glides to every new value and settles with a small bounce instead of jumping
  property real shown: value

  implicitWidth: Theme.resourceRingSize
  implicitHeight: Theme.resourceRingSize

  Behavior on shown {
    SpringAnimation {
      spring: Theme.resourceSpring
      damping: Theme.resourceDamping
      epsilon: 0.001
    }
  }

  Behavior on tint {
    ColorAnimation {
      duration: Theme.indicatorDuration
    }
  }

  Behavior on fillTint {
    ColorAnimation {
      duration: Theme.indicatorDuration
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    color: "transparent"
    border.width: Theme.resourceRingWidth
    border.color: Theme.secondary
  }

  Shape {
    anchors.fill: parent
    visible: root.shown > 0.005
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: "transparent"
      strokeColor: root.fillTint
      strokeWidth: Theme.resourceRingWidth
      capStyle: ShapePath.RoundCap

      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: root.width / 2 - Theme.resourceRingWidth / 2
        radiusY: root.height / 2 - Theme.resourceRingWidth / 2
        startAngle: -90
        sweepAngle: 360 * Math.min(root.shown, 0.999)
      }
    }
  }

  TextMetrics {
    id: glyphMetrics
    font: glyphLabel.font
    text: root.glyph
  }

  // Centered by the ink of the symbol: the line box puts every symbol a little off, each one has its own side bearings and height
  StyledText {
    id: glyphLabel
    x: root.width / 2 - glyphMetrics.tightBoundingRect.x - glyphMetrics.tightBoundingRect.width / 2 + root.nudge.x
    y: root.height / 2 - baselineOffset - glyphMetrics.tightBoundingRect.y - glyphMetrics.tightBoundingRect.height / 2 + root.nudge.y
    color: root.tint
    // Native glyphs snap to whole pixels, which puts an odd-width symbol half a pixel off the middle of an even-size ring, curves are placed exactly
    renderType: Text.CurveRendering
    font.pixelSize: Theme.resourceGlyphSize
    font.weight: Theme.trayFontWeight
    text: root.glyph
  }
}
