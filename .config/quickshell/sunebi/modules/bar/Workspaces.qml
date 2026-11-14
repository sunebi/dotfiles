pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick

import qs
import qs.components

Capsule {
  id: root

  required property HyprlandMonitor monitor

  readonly property int activeIndex: (monitor?.activeWorkspace?.id ?? 0) - 1
  readonly property int cellStride: Theme.workspaceSize + Theme.workspaceSpacing

  // Equal to the vertical inset, so the first and last workspace sit concentric with the round ends
  paddingX: (Theme.barHeight - Theme.workspaceSize) / 2

  function isOccupied(workspaceId) {
    const workspace = Hyprland.workspaces.values.find(candidate => candidate.id === workspaceId);
    return (workspace?.toplevels.values.length ?? 0) > 0;
  }

  function focusWorkspace(workspace) {
    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${workspace} })`);
  }

  Item {
    width: Config.workspaceCount * root.cellStride - Theme.workspaceSpacing
    height: Theme.workspaceSize

    Rectangle {
      visible: mouseArea.containsMouse && mouseArea.hoverIndex !== root.activeIndex
      x: mouseArea.hoverIndex * root.cellStride
      width: Theme.workspaceSize
      height: Theme.workspaceSize
      radius: height / 2
      color: Colors.muted
      opacity: 0.5
    }

    Rectangle {
      visible: root.activeIndex >= 0 && root.activeIndex < Config.workspaceCount
      x: root.activeIndex * root.cellStride
      width: Theme.workspaceSize
      height: Theme.workspaceSize
      radius: height / 2
      color: Colors.secondary

      Behavior on x {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    Repeater {
      model: Config.workspaceCount

      delegate: StyledText {
        id: label

        required property int index
        readonly property int workspaceId: index + 1

        x: index * root.cellStride
        width: Theme.workspaceSize
        height: Theme.workspaceSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: workspaceId
        color: {
          if (index === root.activeIndex)
            return Colors.secondaryForeground;

          return root.isOccupied(workspaceId) ? Colors.foreground : Colors.mutedForeground;
        }
      }
    }

    MouseArea {
      id: mouseArea

      readonly property int hoverIndex: Math.min(Math.floor(mouseX / root.cellStride), Config.workspaceCount - 1)

      anchors.fill: parent
      hoverEnabled: true

      onClicked: root.focusWorkspace(hoverIndex + 1)

      onWheel: wheel => {
        const step = wheel.angleDelta.y > 0 ? 1 : -1;
        const target = root.activeIndex + 1 + step;

        // "r+1" has no upper bound, so stop at the last workspace the bar shows
        if (target < 1 || target > Config.workspaceCount)
          return;

        root.focusWorkspace(step > 0 ? '"r+1"' : '"r-1"');
      }
    }
  }
}
