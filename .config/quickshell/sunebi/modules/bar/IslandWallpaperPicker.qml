import Quickshell.Widgets
import QtQuick

import qs
import qs.services

// The island's content while it is open to choose a wallpaper. Only the selected card is full size, no outlines. The strip stops at its ends instead of centering the first and the last card, so there is no empty space beside it
FocusScope {
  id: root

  property bool active: false
  property int currentIndex: 0

  // The island pads its content by less than the carousel needs, this is the rest
  readonly property int sideMargin: Theme.islandPickerPadding - Theme.islandPaddingX
  readonly property int verticalMargin: Theme.islandPickerPadding - Theme.islandInset

  readonly property int count: Wallpaper.model.count
  readonly property int cardStep: Theme.islandPickerCardWidth + Theme.islandPickerGap
  readonly property real stripWidth: count * cardStep - Theme.islandPickerGap + Theme.islandPickerSelectedCardWidth - Theme.islandPickerCardWidth
  // Centers the selected card, but never moves the strip further than its ends
  readonly property real targetX: Math.max(0, Math.min(currentIndex * cardStep + Theme.islandPickerSelectedCardWidth / 2 - viewport.width / 2, stripWidth - viewport.width))

  function select(index: int): void {
    currentIndex = Math.max(0, Math.min(count - 1, index));
  }

  function choose(path: string): void {
    Wallpaper.apply(path);
    Wallpaper.pickerOpen = false;
  }

  onActiveChanged: {
    if (!active)
      return;
    select(Wallpaper.indexOfCurrent());
    forceActiveFocus();
  }

  Keys.onLeftPressed: select(currentIndex - 1)
  Keys.onRightPressed: select(currentIndex + 1)
  Keys.onReturnPressed: choose(Wallpaper.pathAt(currentIndex))
  Keys.onEnterPressed: choose(Wallpaper.pathAt(currentIndex))
  Keys.onSpacePressed: choose(Wallpaper.pathAt(currentIndex))
  Keys.onEscapePressed: Wallpaper.pickerOpen = false
  // A and D, and the Russian letters on the same keys, because the layout of the keyboard is not known here
  Keys.onPressed: event => {
    const letter = event.text.toLowerCase();
    if (letter === "a" || letter === "ф")
      select(currentIndex - 1);
    else if (letter === "d" || letter === "в")
      select(currentIndex + 1);
  }

  Item {
    id: viewport

    anchors.top: parent.top
    anchors.topMargin: root.verticalMargin
    anchors.left: parent.left
    anchors.leftMargin: root.sideMargin
    anchors.right: parent.right
    anchors.rightMargin: root.sideMargin
    height: Theme.islandPickerSelectedCardWidth * 9 / 16
    clip: true

    Row {
      id: strip

      x: -root.targetX
      height: parent.height
      spacing: Theme.islandPickerGap

      Behavior on x {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }

      Repeater {
        model: Wallpaper.model

        delegate: Item {
          id: cell

          required property int index
          required property string filePath
          readonly property bool selected: index === root.currentIndex

          width: selected ? Theme.islandPickerSelectedCardWidth : Theme.islandPickerCardWidth
          height: strip.height

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
            radius: Theme.islandPickerCardRadius
            color: Theme.muted
            opacity: cell.selected ? 1 : 0.6

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
              sourceSize.height: Theme.islandPickerSelectedCardWidth * 9 / 16 * 2
              // Only the cards around the selected one are loaded, a folder can hold many more than are ever shown
              source: Math.abs(cell.index - root.currentIndex) <= 4 ? "file://" + cell.filePath : ""
            }
          }
        }
      }
    }

    // One area for the click, the drag and the wheel. A drag of one card's width moves the selection by one card, a click without a drag applies the card under the pointer
    MouseArea {
      id: pointer

      property real dragAnchor: 0
      property bool dragged: false
      property real wheelAngle: 0

      anchors.fill: parent

      onPressed: mouse => {
        dragAnchor = mouse.x;
        dragged = false;
      }
      onPositionChanged: mouse => {
        if (Math.abs(mouse.x - dragAnchor) > 6)
          dragged = true;
        if (mouse.x - dragAnchor <= -root.cardStep) {
          root.select(root.currentIndex + 1);
          dragAnchor -= root.cardStep;
        } else if (mouse.x - dragAnchor >= root.cardStep) {
          root.select(root.currentIndex - 1);
          dragAnchor += root.cardStep;
        }
      }
      onReleased: mouse => {
        const cell = strip.childAt(mouse.x - strip.x, mouse.y);
        if (!dragged && cell && cell.filePath)
          root.choose(cell.filePath);
      }
      onWheel: wheel => {
        wheelAngle += wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
        // 120 is one notch of a wheel, a touchpad sends many small values that add up to it
        while (wheelAngle <= -120) {
          root.select(root.currentIndex + 1);
          wheelAngle += 120;
        }
        while (wheelAngle >= 120) {
          root.select(root.currentIndex - 1);
          wheelAngle -= 120;
        }
      }
    }
  }

  StyledText {
    anchors.left: parent.left
    anchors.leftMargin: root.sideMargin
    anchors.right: counter.left
    anchors.rightMargin: Theme.islandPickerPadding
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    color: Theme.mutedForeground
    font.pixelSize: Theme.statusLabelFontSize
    elide: Text.ElideRight
    text: Wallpaper.nameAt(root.currentIndex)
  }

  StyledText {
    id: counter

    anchors.right: parent.right
    anchors.rightMargin: root.sideMargin
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    color: Theme.mutedForeground
    font.pixelSize: Theme.statusLabelFontSize
    text: (root.currentIndex + 1) + "/" + root.count
  }
}
