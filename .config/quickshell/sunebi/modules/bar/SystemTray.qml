pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick

import qs
import qs.services

Item {
  id: root

  // SF Symbols private use glyph of SF Pro Text: chevron.down, flipped by rotation into chevron.up
  readonly property string chevronDown: "\u{100188}"

  readonly property Item overflowPopup: popup

  property bool overflowOpen: false
  // The ghost icon lives in the overlay only while an icon is dragged
  readonly property bool dragging: dragLayer.children.length > 0

  readonly property var pinnedItems: TrayPins.pinnedItems
  readonly property var hiddenItems: TrayPins.hiddenItems

  implicitWidth: capsule.implicitWidth
  implicitHeight: capsule.implicitHeight

  onHiddenItemsChanged: {
    if (hiddenItems.length === 0)
      overflowOpen = false;
  }

  function droppedId(drop: var): string {
    return (drop.source as TrayItem).trayItem.id;
  }

  // Each icon owns the gap up to its neighbors, so only the space around the whole row counts as empty
  function iconAt(repeater: Repeater, area: Item, x: real): TrayItem {
    for (let position = 0; position < repeater.count; position++) {
      const icon = repeater.itemAt(position) as TrayItem;
      const left = icon.mapToItem(area, 0, 0).x - Theme.spacing / 2;
      if (x >= left && x < left + icon.width + Theme.spacing)
        return icon;
    }
    return null;
  }

  // Below the capsule content on purpose, the chevron has its own drop area on top of this one
  DropArea {
    id: trayDropArea

    anchors.fill: capsule
    keys: ["pinned", "hidden"]

    onDropped: drop => {
      const target = root.iconAt(pinnedRepeater, trayDropArea, drop.x);
      if (target)
        TrayPins.place(root.droppedId(drop), target.trayItem.id);
      else
        TrayPins.pin(root.droppedId(drop));
    }
  }

  Capsule {
    id: capsule

    MouseArea {
      // Shown while dragging even if nothing is hidden yet, an icon is hidden by dropping it on the chevron
      visible: root.hiddenItems.length > 0 || root.dragging
      implicitWidth: Theme.trayIconSize
      implicitHeight: Theme.trayIconSize

      onClicked: root.overflowOpen = !root.overflowOpen

      StyledText {
        anchors.centerIn: parent
        text: root.chevronDown
        color: Colors.foreground
        font.weight: Theme.trayFontWeight
        rotation: root.overflowOpen ? 180 : 0

        Behavior on rotation {
          NumberAnimation {
            duration: Theme.indicatorDuration
            easing.type: Easing.OutCubic
          }
        }
      }

      DropArea {
        anchors.fill: parent
        keys: ["pinned"]

        onDropped: drop => TrayPins.unpin(root.droppedId(drop))
      }
    }

    Repeater {
      id: pinnedRepeater

      model: ScriptModel {
        values: root.pinnedItems
      }

      delegate: TrayItem {
        required property SystemTrayItem modelData

        trayItem: modelData
        overlay: dragLayer
        group: "pinned"
      }
    }

    Rectangle {
      visible: root.pinnedItems.length + root.hiddenItems.length > 0
      implicitWidth: 1
      implicitHeight: Theme.trayIconSize
      color: Colors.border
    }

    StatusLabel {
      visible: KeyboardLayout.multiple
      text: KeyboardLayout.current
    }

    StatusLabel {
      visible: Bluetooth.connected
      text: "BT"
    }

    StatusLabel {
      text: DateTime.trayClock
      font.capitalization: Font.MixedCase
      font.pixelSize: Theme.fontSize
    }
  }

  // Lives in the bar window, not a PopupWindow, so a dragged icon can cross between it and the capsule
  Rectangle {
    id: popup

    x: Math.min(0, root.width - width)
    y: capsule.height + Theme.barMarginTop - (root.overflowOpen ? 0 : Theme.spacing)
    opacity: root.overflowOpen ? 1 : 0
    // Zero size once fully faded out keeps the input mask of the bar from covering the windows below
    width: visible ? Math.max(overflowRow.implicitWidth, Theme.trayIconSize) + 2 * Theme.spacing : 0
    height: visible ? Theme.trayPopupHeight : 0
    visible: opacity > 0
    color: Colors.popover
    radius: Theme.radius

    Behavior on opacity {
      NumberAnimation {
        duration: Theme.indicatorDuration
        easing.type: Easing.OutCubic
      }
    }

    Behavior on y {
      NumberAnimation {
        duration: Theme.indicatorDuration
        easing.type: Easing.OutCubic
      }
    }

    Row {
      id: overflowRow

      anchors.centerIn: parent
      spacing: Theme.spacing

      Repeater {
        id: hiddenRepeater

        model: ScriptModel {
          values: root.hiddenItems
        }

        delegate: TrayItem {
          required property SystemTrayItem modelData

          trayItem: modelData
          overlay: dragLayer
          group: "hidden"
        }
      }
    }

    DropArea {
      id: overflowDropArea

      anchors.fill: parent
      // Reordering only, hiding an icon takes a drop on the chevron
      keys: ["hidden"]

      onDropped: drop => {
        const target = root.iconAt(hiddenRepeater, overflowDropArea, drop.x);
        if (target)
          TrayPins.place(root.droppedId(drop), target.trayItem.id);
        else
          TrayPins.unpin(root.droppedId(drop));
      }
    }
  }

  Item {
    id: dragLayer

    z: 1
  }

  // Clicking the bar keeps the popup open so the chevron can close it, any other window dismisses it
  HyprlandFocusGrab {
    active: root.overflowOpen
    windows: [root.QsWindow.window]
    onCleared: root.overflowOpen = false
  }
}
