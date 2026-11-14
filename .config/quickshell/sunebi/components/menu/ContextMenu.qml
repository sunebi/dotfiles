pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs

// A context menu in the look of shadcn/ui: a popover with a hairline border, rows that light up under the pointer, separators, marks and a chevron for a submenu. It lists the entries of a menu handle, the ones a tray app gives, and a submenu is another ContextMenu next to its row. A popup window of its own grabs the focus, so a click anywhere else closes it. It has no border, the color of the popover against what is behind it is enough
PopupWindow {
  id: root

  // The menu handle of a tray item, or the entry that has children
  required property var menu
  // The first menu is placed by its opener, which sets the anchor, the right edge it ends at on the screen, the width of that screen and the side its submenus try first
  property real anchorRight: 0
  property real screenWidth: 0
  property bool submenusPreferLeft: false
  // A submenu is placed by the menu it opens from and sits on the left or on the right of it. Choosing an entry closes the whole chain
  property var parentMenu: null
  property bool onLeftOfParent: false
  // The left edge on the screen, a submenu works it out from its parent, so the next level knows how much room is left
  readonly property real screenX: {
    if (parentMenu === null)
      return anchorRight - implicitWidth;
    return onLeftOfParent ? parentMenu.screenX - Theme.menuSubmenuGap - implicitWidth : parentMenu.screenX + parentMenu.implicitWidth + Theme.menuSubmenuGap;
  }
  // The row whose submenu is open, and that submenu
  property int openedIndex: -1
  property var submenuPopup: null

  function closeAll(): void {
    if (parentMenu)
      parentMenu.closeAll();
    else
      visible = false;
  }

  // A submenu follows the side its menu is on and turns around only when it would leave the screen. The compositor could flip it too, but then it lands on the menu it comes from, because that menu is no edge to it
  function submenuOnLeft(): bool {
    const wantsLeft = parentMenu === null ? submenusPreferLeft : onLeftOfParent;
    const room = Theme.menuMinWidth + Theme.menuSubmenuGap;
    const fitsLeft = screenX - room >= 0;
    const fitsRight = screenX + implicitWidth + room <= screenWidth;
    if (wantsLeft)
      return fitsLeft || !fitsRight;
    return !fitsRight && fitsLeft;
  }

  // Made when it is needed: a type cannot instantiate itself in its own file, a component made by its file name can
  function openSubmenu(row: Item, index: int): void {
    if (openedIndex === index)
      return;
    closeSubmenu();
    const onLeft = submenuOnLeft();
    const popup = Qt.createComponent("ContextMenu.qml").createObject(root, {
      menu: row.entry,
      parentMenu: root,
      screenWidth: screenWidth,
      onLeftOfParent: onLeft
    });
    // Anchored to this window by a rect, with an item set the rect is ignored and the submenu lands on its row. The point is on the edge the submenu hangs from, level with this row
    const rowPosition = row.mapToItem(null, 0, 0);
    popup.anchor.window = root;
    popup.anchor.rect = Qt.rect(onLeft ? -Theme.menuSubmenuGap : implicitWidth + Theme.menuSubmenuGap, rowPosition.y - Theme.menuPadding, 0, 0);
    popup.anchor.edges = Edges.Top | Edges.Left;
    popup.anchor.gravity = onLeft ? Edges.Bottom | Edges.Left : Edges.Bottom | Edges.Right;
    popup.anchor.adjustment = PopupAdjustment.SlideY;
    popup.visible = true;
    submenuPopup = popup;
    openedIndex = index;
  }

  function closeSubmenu(): void {
    submenuPopup?.destroy();
    submenuPopup = null;
    openedIndex = -1;
  }

  implicitWidth: Math.max(Theme.menuMinWidth, column.implicitWidth + 2 * Theme.menuPadding)
  implicitHeight: column.implicitHeight + 2 * Theme.menuPadding
  color: "transparent"
  grabFocus: true

  onVisibleChanged: {
    if (!visible)
      closeSubmenu();
  }

  QsMenuOpener {
    id: opener

    menu: root.menu
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Colors.popover

    // A layout takes the implicit width of its rows, so the menu grows with its widest entry. A Column would take their current width, which is the width of the menu
    ColumnLayout {
      id: column

      x: Theme.menuPadding
      y: Theme.menuPadding
      width: root.implicitWidth - 2 * Theme.menuPadding
      spacing: 0

      Repeater {
        model: opener.children

        delegate: ContextMenuItem {
          id: row

          required property int index
          required property var modelData

          entry: modelData
          Layout.fillWidth: true
          submenuOpen: root.openedIndex === index

          onHovered: {
            if (entry.hasChildren)
              root.openSubmenu(row, index);
            else
              root.closeSubmenu();
          }
          onActivated: {
            if (entry.hasChildren) {
              root.openSubmenu(row, index);
              return;
            }
            entry.triggered();
            root.closeAll();
          }
        }
      }
    }
  }
}
