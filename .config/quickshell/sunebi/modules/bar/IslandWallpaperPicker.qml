import Quickshell.Widgets
import QtQuick

import qs
import qs.services

// The island's content while it is open to choose a wallpaper. Only the selected card is full size, no outlines, the dot marks the wallpaper on the screens
FocusScope {
  id: root

  property bool active: false

  // The island pads its content by less than the carousel needs, this is the rest
  readonly property int sideMargin: Theme.islandPickerPadding - Theme.islandPaddingX
  readonly property int verticalMargin: Theme.islandPickerPadding - Theme.islandInset

  function choose(path: string): void {
    Wallpaper.apply(path);
    Wallpaper.pickerOpen = false;
  }

  onActiveChanged: {
    if (!active)
      return;
    list.currentIndex = Math.max(0, Wallpaper.indexOfCurrent());
    list.positionViewAtIndex(list.currentIndex, ListView.Center);
    forceActiveFocus();
  }

  Keys.onLeftPressed: list.decrementCurrentIndex()
  Keys.onRightPressed: list.incrementCurrentIndex()
  Keys.onReturnPressed: choose(Wallpaper.pathAt(list.currentIndex))
  Keys.onEnterPressed: choose(Wallpaper.pathAt(list.currentIndex))
  Keys.onSpacePressed: choose(Wallpaper.pathAt(list.currentIndex))
  Keys.onEscapePressed: Wallpaper.pickerOpen = false

  ListView {
    id: list

    anchors.top: parent.top
    anchors.topMargin: root.verticalMargin
    anchors.left: parent.left
    anchors.leftMargin: root.sideMargin
    anchors.right: parent.right
    anchors.rightMargin: root.sideMargin
    height: Theme.islandPickerSelectedCardWidth * 9 / 16
    orientation: ListView.Horizontal
    spacing: Theme.islandPickerGap
    clip: true
    model: Wallpaper.model
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: (width - Theme.islandPickerSelectedCardWidth) / 2
    preferredHighlightEnd: (width + Theme.islandPickerSelectedCardWidth) / 2
    highlightMoveDuration: Theme.indicatorDuration
    // The keys are handled by the scope around, the list has no focus of its own
    interactive: false

    delegate: Item {
      id: cell

      required property string filePath
      readonly property bool selected: ListView.isCurrentItem

      width: selected ? Theme.islandPickerSelectedCardWidth : Theme.islandPickerCardWidth
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
          source: "file://" + cell.filePath
        }

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
    anchors.leftMargin: root.sideMargin
    anchors.right: counter.left
    anchors.rightMargin: Theme.islandPickerPadding
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    color: Theme.mutedForeground
    font.pixelSize: Theme.statusLabelFontSize
    elide: Text.ElideRight
    text: Wallpaper.nameAt(list.currentIndex)
  }

  StyledText {
    id: counter

    anchors.right: parent.right
    anchors.rightMargin: root.sideMargin
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    color: Theme.mutedForeground
    font.pixelSize: Theme.statusLabelFontSize
    text: (list.currentIndex + 1) + "/" + Wallpaper.model.count
  }
}
