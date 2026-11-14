import Quickshell
import QtQuick

import qs
import qs.components

// One row of a context menu, a separator or an entry. The text is on the left, on the right is the chevron of a submenu or the mark of a checked entry. A disabled entry is dimmed and does not react
Item {
  id: root

  required property QsMenuEntry entry
  // The row lights up while its submenu is open, not only under the pointer
  required property bool submenuOpen

  signal hovered
  signal activated

  // SF Symbols private use glyphs of SF Pro Text: checkmark, chevron.right and circle.fill
  readonly property string checkGlyph: "\u{100185}"
  readonly property string chevronGlyph: "\u{10018A}"
  readonly property string dotGlyph: "\u{100001}"

  readonly property bool highlighted: entry.enabled && (mouseArea.containsMouse || submenuOpen)
  readonly property bool checked: entry.buttonType !== QsMenuButtonType.None && entry.checkState === Qt.Checked
  readonly property string indicator: {
    if (entry.hasChildren)
      return chevronGlyph;
    if (!checked)
      return "";
    return entry.buttonType === QsMenuButtonType.RadioButton ? dotGlyph : checkGlyph;
  }

  implicitWidth: label.implicitWidth + 2 * Theme.menuItemPaddingX + Theme.menuIndicatorWidth
  implicitHeight: entry.isSeparator ? Theme.menuSeparatorHeight : Theme.menuItemHeight

  Rectangle {
    visible: !root.entry.isSeparator
    anchors.fill: parent
    radius: Theme.radius - Theme.menuPadding
    color: root.highlighted ? Colors.accent : "transparent"
  }

  // As wide as the menu, over the padding of the rows, like the separators of shadcn/ui
  Rectangle {
    visible: root.entry.isSeparator
    anchors.left: parent.left
    anchors.leftMargin: -Theme.menuPadding
    anchors.right: parent.right
    anchors.rightMargin: -Theme.menuPadding
    anchors.verticalCenter: parent.verticalCenter
    height: 1
    color: Colors.border
  }

  StyledText {
    id: label

    visible: !root.entry.isSeparator
    anchors.left: parent.left
    anchors.leftMargin: Theme.menuItemPaddingX
    anchors.verticalCenter: parent.verticalCenter
    color: root.highlighted ? Colors.accentForeground : Colors.popoverForeground
    opacity: root.entry.enabled ? 1 : 0.5
    text: root.entry.text
  }

  StyledText {
    anchors.right: parent.right
    anchors.rightMargin: Theme.menuItemPaddingX
    anchors.verticalCenter: parent.verticalCenter
    color: label.color
    opacity: label.opacity
    // The dot of a radio entry is a smaller circle than a mark
    font.pixelSize: root.indicator === root.dotGlyph ? Theme.fontSize - 6 : Theme.fontSize - 1
    font.weight: Theme.trayFontWeight
    text: root.indicator
  }

  MouseArea {
    id: mouseArea

    enabled: !root.entry.isSeparator
    anchors.fill: parent
    hoverEnabled: true

    onEntered: root.hovered()
    onClicked: {
      if (root.entry.enabled)
        root.activated();
    }
  }
}
