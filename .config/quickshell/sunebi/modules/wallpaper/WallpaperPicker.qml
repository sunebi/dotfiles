import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

import qs
import qs.services
import qs.modules.bar

// A full-screen transparent window, so a click outside the panel closes it and the arrow keys reach it, shown only on the screen that has the focus
PanelWindow {
  id: root

  required property var modelData

  readonly property bool shown: Wallpaper.pickerOpen && Hyprland.monitorFor(modelData) === Hyprland.focusedMonitor

  function choose(path: string): void {
    Wallpaper.apply(path);
    Wallpaper.pickerOpen = false;
  }

  screen: modelData
  visible: shown
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  WlrLayershell.namespace: "sunebi-wallpaper"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onShownChanged: {
    if (!shown)
      return;
    list.currentIndex = Math.max(0, Wallpaper.indexOfCurrent());
    list.positionViewAtIndex(list.currentIndex, ListView.Center);
    keys.forceActiveFocus();
    appear.restart();
  }

  MouseArea {
    anchors.fill: parent
    onClicked: Wallpaper.pickerOpen = false
  }

  Rectangle {
    id: panel

    anchors.centerIn: parent
    width: Theme.pickerWidth
    height: Theme.pickerHeight
    radius: 24
    color: Theme.background
    border.width: 1
    border.color: Theme.border

    NumberAnimation {
      id: appear

      target: panel
      property: "opacity"
      from: 0
      to: 1
      duration: Theme.indicatorDuration
      easing.type: Easing.OutCubic
    }

    // The empty parts of the panel must not count as a click outside
    MouseArea {
      anchors.fill: parent
    }

    FocusScope {
      id: keys

      anchors.fill: parent
      focus: true

      Keys.onLeftPressed: list.decrementCurrentIndex()
      Keys.onRightPressed: list.incrementCurrentIndex()
      Keys.onReturnPressed: root.choose(Wallpaper.pathAt(list.currentIndex))
      Keys.onEnterPressed: root.choose(Wallpaper.pathAt(list.currentIndex))
      Keys.onSpacePressed: root.choose(Wallpaper.pathAt(list.currentIndex))
      Keys.onEscapePressed: Wallpaper.pickerOpen = false

      ListView {
        id: list

        anchors.top: parent.top
        anchors.topMargin: Theme.pickerPadding
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.pickerSelectedCardWidth * 9 / 16 + Theme.pickerPadding
        orientation: ListView.Horizontal
        spacing: Theme.spacing + 4
        clip: true
        model: Wallpaper.model
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width - Theme.pickerSelectedCardWidth) / 2
        preferredHighlightEnd: (width + Theme.pickerSelectedCardWidth) / 2
        highlightMoveDuration: Theme.indicatorDuration
        // The keys are handled by the scope around, the list has no focus of its own
        interactive: false

        delegate: Item {
          id: cell

          required property int index
          required property string filePath
          readonly property bool selected: ListView.isCurrentItem

          width: selected ? Theme.pickerSelectedCardWidth : Theme.pickerCardWidth
          height: ListView.view.height

          Behavior on width {
            NumberAnimation {
              duration: Theme.indicatorDuration
              easing.type: Easing.OutCubic
            }
          }

          ClippingRectangle {
            anchors.centerIn: parent
            width: parent.width
            height: width * 9 / 16
            radius: Theme.radius * 1.5
            color: Theme.muted
            opacity: cell.selected ? 1 : 0.55

            Behavior on opacity {
              NumberAnimation {
                duration: Theme.indicatorDuration
              }
            }

            Image {
              anchors.fill: parent
              asynchronous: true
              fillMode: Image.PreserveAspectCrop
              // A fixed size, so the decoder does not run again while the card grows
              sourceSize.height: Theme.pickerSelectedCardWidth * 9 / 16 * 2
              source: "file://" + cell.filePath
            }

            Rectangle {
              anchors.fill: parent
              radius: parent.radius
              color: "transparent"
              border.width: 1
              border.color: cell.selected ? Theme.ring : "transparent"
            }

            // Marks the wallpaper that is on the screens now
            Rectangle {
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: Theme.spacing
              width: 8
              height: width
              radius: width / 2
              color: Theme.primary
              visible: cell.filePath === Wallpaper.current
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: root.choose(cell.filePath)
          }
        }
      }

      StyledText {
        anchors.left: parent.left
        anchors.leftMargin: Theme.pickerPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.pickerPadding * 2 / 3
        color: Theme.mutedForeground
        font.pixelSize: Theme.statusLabelFontSize
        // The counter keeps its place, the name gives way
        anchors.right: counter.left
        anchors.rightMargin: Theme.pickerPadding
        elide: Text.ElideRight
        text: Wallpaper.nameAt(list.currentIndex)
      }

      StyledText {
        id: counter

        anchors.right: parent.right
        anchors.rightMargin: Theme.pickerPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.pickerPadding * 2 / 3
        color: Theme.mutedForeground
        font.pixelSize: Theme.statusLabelFontSize
        text: (list.currentIndex + 1) + "/" + Wallpaper.model.count
      }
    }
  }
}
