pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs

Singleton {
  id: root

  property var windowList: []
  property var windowByAddress: ({})
  property var workspaces: []
  property var workspaceById: ({})
  property var activeWorkspace: null
  property var monitors: []
  property var layers: ({})

  function indexBy(items, key) {
    const index = {};

    for (const item of items)
      index[item[key]] = item;

    return index;
  }

  function addressOf(toplevel) {
    const address = toplevel?.HyprlandToplevel?.address;
    return address === undefined ? null : `0x${address}`;
  }

  function clientForToplevel(toplevel) {
    return windowByAddress[addressOf(toplevel)] ?? null;
  }

  function toplevelsForWorkspace(workspaceId) {
    return ToplevelManager.toplevels.values.filter(toplevel => {
      const client = clientForToplevel(toplevel);
      return client?.workspace?.id === workspaceId;
    });
  }

  function hyprlandClientsForWorkspace(workspaceId) {
    return windowList.filter(window => window.workspace.id === workspaceId);
  }

  function biggestWindowForWorkspace(workspaceId) {
    let biggestWindow = null;
    let biggestArea = 0;

    for (const window of hyprlandClientsForWorkspace(workspaceId)) {
      const area = window.size[0] * window.size[1];

      if (area > biggestArea) {
        biggestWindow = window;
        biggestArea = area;
      }
    }

    return biggestWindow;
  }

  function updateAll() {
    getClients.running = true;
    getMonitors.running = true;
    getLayers.running = true;
    getWorkspaces.running = true;
    getActiveWorkspace.running = true;
  }

  Component.onCompleted: updateAll()

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (["openlayer", "closelayer", "screencast"].includes(event.name))
        return;

      root.updateAll();
    }
  }

  Process {
    id: getClients
    command: ["hyprctl", "clients", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        root.windowList = JSON.parse(text);
        root.windowByAddress = root.indexBy(root.windowList, "address");
      }
    }
  }

  Process {
    id: getMonitors
    command: ["hyprctl", "monitors", "-j"]

    stdout: StdioCollector {
      onStreamFinished: root.monitors = JSON.parse(text)
    }
  }

  Process {
    id: getLayers
    command: ["hyprctl", "layers", "-j"]

    stdout: StdioCollector {
      onStreamFinished: root.layers = JSON.parse(text)
    }
  }

  Process {
    id: getWorkspaces
    command: ["hyprctl", "workspaces", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        const allWorkspaces = JSON.parse(text);

        root.workspaces = allWorkspaces.filter(workspace => workspace.id >= 1 && workspace.id <= Config.lastRegularWorkspaceId);
        root.workspaceById = root.indexBy(root.workspaces, "id");
      }
    }
  }

  Process {
    id: getActiveWorkspace
    command: ["hyprctl", "activeworkspace", "-j"]

    stdout: StdioCollector {
      onStreamFinished: root.activeWorkspace = JSON.parse(text)
    }
  }
}
