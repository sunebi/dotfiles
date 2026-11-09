pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
  id: root

  readonly property bool available: Bluetooth.adapters.values.length > 0
  readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
  readonly property bool connected: connectedDevices.length > 0

  readonly property list<var> connectedDevices: sortedDevices(device => device.connected)
  readonly property list<var> pairedButNotConnectedDevices: sortedDevices(device => device.paired && !device.connected)
  readonly property list<var> unpairedDevices: sortedDevices(device => !device.paired && !device.connected)
  readonly property list<var> friendlyDeviceList: [...connectedDevices, ...pairedButNotConnectedDevices, ...unpairedDevices]

  function sortedDevices(predicate) {
    return Bluetooth.devices.values.filter(predicate).sort(compareDevices);
  }

  // Devices with a real name come before those still named by their MAC address
  function compareDevices(a, b) {
    const macAddressPattern = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
    const aIsMacAddress = macAddressPattern.test(a.name);
    const bIsMacAddress = macAddressPattern.test(b.name);

    if (aIsMacAddress !== bIsMacAddress)
      return aIsMacAddress ? 1 : -1;

    return a.name.localeCompare(b.name);
  }
}
