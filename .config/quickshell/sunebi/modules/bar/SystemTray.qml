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
  // The popup also appears during a drag, otherwise an empty one could never receive an icon
  readonly property bool popupShown: overflowOpen || dragging

  readonly property var pinnedItems: TrayPins.pinnedIds.map(id => SystemTray.items.values.find(item => item.id === id)).filter(item => item !== undefined)
  readonly property var hiddenItems: SystemTray.items.values.filter(item => !TrayPins.isPinned(item.id))

  implicitWidth: capsule.implicitWidth
  implicitHeight: capsule.implicitHeight

  onHiddenItemsChanged: {
    if (hiddenItems.length === 0)
      overflowOpen = false;
  }

  // Each icon owns the gap up to its neighbors, so only the space around the whole row counts as empty
  function pinnedIconAt(x: real): Item {
    for (let position = 0; position < pinnedRepeater.count; position++) {
      const icon = pinnedRepeater.itemAt(position);
      const left = icon.mapToItem(trayDropArea, 0, 0).x - Theme.spacing / 2;
      if (x >= left && x < left + icon.width + Theme.spacing)
        return icon;
    }
    return null;
  }

  Capsule {
    id: capsule

    MouseArea {
      visible: root.hiddenItems.length > 0
      implicitWidth: Theme.trayIconSize
      implicitHeight: Theme.trayIconSize

      onClicked: root.overflowOpen = !root.overflowOpen

      StyledText {
        anchors.centerIn: parent
        text: root.chevronDown
        color: Theme.foreground
        rotation: root.overflowOpen ? 180 : 0

        Behavior on rotation {
          NumberAnimation {
            duration: Theme.indicatorDuration
            easing.type: Easing.OutCubic
          }
        }
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
      }
    }

    Rectangle {
      visible: SystemTray.items.values.length > 0
      implicitWidth: 1
      implicitHeight: Theme.trayIconSize
      color: Theme.border
    }

    StyledText {
      visible: Bluetooth.connected
      text: "BT"
      color: Theme.mutedForeground
    }

    StyledText {
      text: `${Math.round(Audio.volume * 100)}%`
      color: Theme.mutedForeground
    }
  }

  DropArea {
    id: trayDropArea

    anchors.fill: capsule
    keys: ["trayItem"]

    onDropped: drop => {
      const target = root.pinnedIconAt(drop.x);
      if (target)
        TrayPins.place(drop.source.trayItem.id, target.trayItem.id);
      else
        TrayPins.pin(drop.source.trayItem.id);
    }
  }

  // Lives in the bar window, not a PopupWindow, so a dragged icon can cross between it and the capsule
  Rectangle {
    id: popup

    x: Math.min(0, root.width - width)
    y: capsule.height + Theme.barMarginTop
    // Zero size while closed keeps the input mask of the bar from covering the windows below
    width: root.popupShown ? Math.max(overflowRow.implicitWidth, Theme.trayIconSize) + 2 * Theme.spacing : 0
    height: root.popupShown ? Theme.trayPopupHeight : 0
    visible: root.popupShown
    color: Theme.popover
    radius: Theme.radius

    Row {
      id: overflowRow

      anchors.centerIn: parent
      spacing: Theme.spacing

      Repeater {
        model: ScriptModel {
          values: root.hiddenItems
        }

        delegate: TrayItem {
          required property SystemTrayItem modelData

          trayItem: modelData
          overlay: dragLayer
        }
      }
    }

    DropArea {
      anchors.fill: parent
      keys: ["trayItem"]

      onDropped: drop => TrayPins.unpin(drop.source.trayItem.id)
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
