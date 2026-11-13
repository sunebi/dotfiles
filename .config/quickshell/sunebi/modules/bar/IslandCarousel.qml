import Quickshell.Widgets
import QtQuick

import qs
import qs.services

// The island's content while it is open to choose one of many pictures, the wallpapers or the cursor themes. The model has a filePath role with the picture of every item. Only the selected card is full size, no outlines. The strip stops at its ends instead of centering the first and the last card, so there is no empty space beside it
FocusScope {
  id: root

  required property var model
  // What the footer says about the item at the index
  property var nameAt: index => ""
  // The item that is selected when the carousel opens
  property int startIndex: 0
  property int fillMode: Image.PreserveAspectCrop
  property int imagePadding: 0
  property bool active: false
  property int currentIndex: 0

  signal chosen(int index)
  signal dismissed
  // False for the moment the carousel opens, so the strip and the cards are put in place instead of sliding there from where the last use left them
  property bool animated: true

  // The island pads its content by less than the carousel needs, this is the rest
  readonly property int sideMargin: Theme.islandPickerPadding - Theme.islandPaddingX
  readonly property int verticalMargin: Theme.islandPickerPadding - Theme.islandInset

  readonly property int count: model.count
  readonly property int cardStep: Theme.islandPickerCardWidth + Theme.islandPickerGap
  readonly property real stripWidth: count * cardStep - Theme.islandPickerGap + Theme.islandPickerSelectedCardWidth - Theme.islandPickerCardWidth
  // The width the strip has once the island is fully open. The island grows while it opens, a target that followed it would keep moving
  readonly property real viewportWidth: Theme.islandPickerWidth - 2 * Theme.islandPickerPadding
  // Centers the selected card, but never moves the strip further than its ends
  readonly property real targetX: Math.max(0, Math.min(currentIndex * cardStep + Theme.islandPickerSelectedCardWidth / 2 - viewportWidth / 2, stripWidth - viewportWidth))

  function select(index: int): void {
    currentIndex = Math.max(0, Math.min(count - 1, index));
  }

  onActiveChanged: {
    if (!active)
      return;
    animated = false;
    select(startIndex);
    animated = true;
    forceActiveFocus();
  }

  Keys.onLeftPressed: select(currentIndex - 1)
  Keys.onRightPressed: select(currentIndex + 1)
  Keys.onReturnPressed: chosen(currentIndex)
  Keys.onEnterPressed: chosen(currentIndex)
  Keys.onSpacePressed: chosen(currentIndex)
  Keys.onEscapePressed: dismissed()
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
    // Never taller than the island has grown so far, so the cards do not stick out of it while it opens and closes
    height: Math.max(0, Math.min(Theme.islandPickerSelectedCardWidth * 9 / 16, root.height - 2 * root.verticalMargin - Theme.islandPickerGap - Theme.islandPickerFooterHeight))
    clip: true

    Row {
      id: strip

      x: -root.targetX
      height: parent.height
      spacing: Theme.islandPickerGap

      Behavior on x {
        enabled: root.animated

        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }

      Repeater {
        model: root.model

        delegate: Item {
          id: cell

          required property int index
          required property string filePath
          readonly property bool selected: index === root.currentIndex

          width: selected ? Theme.islandPickerSelectedCardWidth : Theme.islandPickerCardWidth
          height: strip.height

          Behavior on width {
            enabled: root.animated

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
              enabled: root.animated

              NumberAnimation {
                duration: Theme.indicatorDuration
              }
            }

            Image {
              anchors.fill: parent
              anchors.margins: root.imagePadding
              asynchronous: true
              fillMode: root.fillMode
              // A fixed size, so the decoder does not run again while the card grows
              sourceSize.height: Theme.islandPickerSelectedCardWidth * 9 / 16 * 2
              // Only the cards around the selected one are loaded, a folder can hold many more than are ever shown
              source: Math.abs(cell.index - root.currentIndex) <= 4 ? "file://" + cell.filePath : ""
            }
          }
        }
      }
    }

    // A click applies the card under the pointer, the wheel moves the selection
    MouseArea {
      property real wheelAngle: 0

      anchors.fill: parent

      onClicked: mouse => {
        const cell = strip.childAt(mouse.x - strip.x, mouse.y);
        if (cell && cell.filePath !== undefined)
          root.chosen(cell.index);
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
    text: root.nameAt(root.currentIndex)
  }

  StyledText {
    id: counter

    anchors.right: parent.right
    anchors.rightMargin: root.sideMargin
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    color: Theme.mutedForeground
    font.pixelSize: Theme.statusLabelFontSize
    text: (root.currentIndex + 1) + " / " + root.count
  }
}
