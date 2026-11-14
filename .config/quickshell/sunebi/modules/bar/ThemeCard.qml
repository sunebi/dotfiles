import QtQuick

import qs
import qs.services

// The card of a theme in the carousel: its background, the look of its text and, on a tile of its secondary color, the colors that tell it apart. The carousel gives the row of the model and whether the card is selected to the Loader this sits in. The outline is the border color of the theme itself, the selected card wears a ring of its primary color
Item {
  readonly property var tokens: Themes.tokensOf(parent.row.themeId)
  readonly property bool selected: parent.selected

  Rectangle {
    anchors.fill: parent
    color: tokens.background ?? "transparent"
  }

  StyledText {
    anchors.left: parent.left
    anchors.leftMargin: 12
    anchors.top: parent.top
    anchors.topMargin: 8
    color: tokens.foreground ?? "transparent"
    font.pixelSize: 22
    font.weight: Font.DemiBold
    text: "Aa"
  }

  // Concentric with the card: the card radius less the margin
  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 8
    height: 28
    radius: Theme.islandPickerCardRadius - 8
    color: tokens.secondary ?? "transparent"

    Row {
      anchors.left: parent.left
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      Repeater {
        model: [tokens.primary, tokens.mutedForeground, tokens.destructive]

        delegate: Rectangle {
          required property color modelData

          width: 14
          height: 14
          radius: 7
          color: modelData
        }
      }
    }
  }

  // Drawn last so it lies over the content
  Rectangle {
    anchors.fill: parent
    radius: Theme.islandPickerCardRadius
    color: "transparent"
    border.width: selected ? 2 : 1
    border.color: (selected ? tokens.primary : tokens.border) ?? "transparent"

    Behavior on border.color {
      ColorAnimation {
        duration: Theme.indicatorDuration
      }
    }
  }
}
