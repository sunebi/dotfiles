import QtQuick
import QtQuick.Shapes

import qs

// A round button of the session menu. A button that has to be held shows how far the hold is in a ring around it and runs only when the ring is full
Item {
  id: root

  required property string glyph
  required property bool hold
  property bool focused: false
  property real progress: 0

  signal activated
  signal entered

  // The keyboard presses and releases, the mouse does the same through the area below
  function press(): void {
    if (!hold) {
      activated();
      return;
    }
    drain.stop();
    fill.duration = Config.sessionHoldMs * (1 - progress);
    fill.restart();
  }

  function release(): void {
    if (!hold)
      return;
    fill.stop();
    drain.restart();
  }

  implicitWidth: Theme.islandSessionButtonSize
  implicitHeight: Theme.islandSessionButtonSize

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    // Ghost: no background until the pointer or the keyboard is on the button, the alpha of the same color is animated so it does not pass through black
    color: root.focused ? Theme.secondary : Qt.alpha(Theme.secondary, 0)

    Behavior on color {
      ColorAnimation {
        duration: Theme.indicatorDuration / 2
      }
    }

    // What is held is tinted red while it is the one in focus
    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: Qt.alpha(Theme.destructive, 0.2)
      opacity: root.hold && root.focused ? 1 : 0

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration / 2
        }
      }
    }
  }

  StyledText {
    anchors.centerIn: parent
    color: root.hold && root.focused ? Theme.destructive : Theme.foreground
    font.pixelSize: 16
    font.weight: Theme.trayFontWeight
    text: root.glyph
  }

  Shape {
    anchors.fill: parent
    visible: root.progress > 0
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: "transparent"
      strokeColor: Theme.destructive
      strokeWidth: 2
      capStyle: ShapePath.RoundCap

      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: root.width / 2 - 1
        radiusY: root.height / 2 - 1
        startAngle: -90
        sweepAngle: 360 * root.progress
      }
    }
  }

  NumberAnimation {
    id: fill

    target: root
    property: "progress"
    to: 1

    // Stopped by a release comes back here too, only a full ring runs the action
    onStopped: {
      if (root.progress >= 1) {
        root.progress = 0;
        root.activated();
      }
    }
  }

  NumberAnimation {
    id: drain

    target: root
    property: "progress"
    to: 0
    duration: 200
    easing.type: Easing.OutCubic
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: root.entered()
    onPressed: {
      if (root.hold)
        root.press();
    }
    onReleased: root.release()
    onCanceled: root.release()
    onClicked: {
      if (!root.hold)
        root.activated();
    }
  }
}
