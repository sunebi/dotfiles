import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import qs
import qs.components.menu

IconImage {
  id: root

  required property SystemTrayItem trayItem
  // The dragged copy is moved here while dragging, so neither the capsule nor the popup can cover it
  required property Item overlay
  // Where the icon lives, "pinned" or "hidden": the drop areas only take icons from the places they make sense for
  required property string group
  readonly property bool menuOpen: contextMenu.visible

  // The item is destroyed when its app quits, a moment before the model drops this delegate
  source: trayItem ? trayItem.icon : ""
  implicitSize: Theme.trayIconSize
  opacity: mouseArea.drag.active ? 0.4 : 1

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    drag.target: ghost
    // The default threshold leaves the dragged icon visibly behind the cursor
    drag.threshold: Theme.dragThreshold

    onReleased: ghost.Drag.drop()
    onClicked: mouse => {
      // activate() on menu-only items can close the app
      if (mouse.button === Qt.LeftButton && !root.trayItem.onlyMenu) {
        root.trayItem.activate();
        return;
      }

      if (root.trayItem.hasMenu)
        root.toggleMenu();
    }
  }

  // The anchor is fixed when the menu opens: an icon in the overflow popup moves away as soon as that popup closes, and the menu stays where it was opened
  function toggleMenu(): void {
    if (contextMenu.visible) {
      contextMenu.visible = false;
      return;
    }
    const position = root.QsWindow.mapFromItem(root, 0, 0);
    // From the icon down past the capsule, so the menu hangs a gap below the bar and ends where the icon ends
    contextMenu.anchor.rect = Qt.rect(position.x, position.y, root.width, root.height + (Theme.barHeight - Theme.trayIconSize) / 2 + Theme.menuGap);
    // The menu hangs from the right edge of the icon to the left, so its submenus go the same way
    contextMenu.anchorRight = position.x + root.width;
    contextMenu.screenWidth = root.QsWindow.window.screen.width;
    contextMenu.submenusPreferLeft = true;
    contextMenu.visible = true;
  }

  ContextMenu {
    id: contextMenu

    menu: root.trayItem?.menu
    anchor.window: root.QsWindow.window
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.adjustment: PopupAdjustment.Slide
  }

  IconImage {
    id: ghost

    visible: Drag.active
    source: root.source
    implicitSize: root.implicitSize

    Drag.active: mouseArea.drag.active
    Drag.source: root
    Drag.keys: [root.group]
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.onDragFinished: {
      x = 0;
      y = 0;
    }

    states: State {
      when: ghost.Drag.active

      ParentChange {
        target: ghost
        parent: root.overlay
      }
    }
  }
}
