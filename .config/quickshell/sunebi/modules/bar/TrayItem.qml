import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import qs

IconImage {
  id: root

  required property SystemTrayItem trayItem
  // The dragged copy is moved here while dragging, so neither the capsule nor the popup can cover it
  required property Item overlay

  source: trayItem.icon
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

      if (!root.trayItem.hasMenu)
        return;

      const menuPosition = root.QsWindow.mapFromItem(root, 0, root.height);
      root.trayItem.display(root.QsWindow.window, menuPosition.x, menuPosition.y);
    }
  }

  IconImage {
    id: ghost

    visible: Drag.active
    source: root.source
    implicitSize: root.implicitSize

    Drag.active: mouseArea.drag.active
    Drag.source: root
    Drag.keys: ["trayItem"]
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
