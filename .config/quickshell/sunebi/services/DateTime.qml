pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs

Singleton {
  id: root

  readonly property string time: formatted(Config.timeFormat)
  readonly property string shortDate: formatted(Config.shortDateFormat)
  readonly property string date: formatted(Config.dateFormat)
  readonly property string longDate: formatted(Config.longDateFormat)
  readonly property string collapsedCalendarDate: formatted(Config.collapsedCalendarDateFormat)
  property string uptime: "0m"

  function formatted(pattern) {
    return Qt.locale().toString(clock.date, pattern);
  }

  function formatUptime(totalSeconds) {
    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor(totalSeconds % 86400 / 3600);
    const minutes = Math.floor(totalSeconds % 3600 / 60);

    const parts = [];
    if (days > 0)
      parts.push(`${days}d`);
    if (hours > 0)
      parts.push(`${hours}h`);
    if (minutes > 0 || parts.length === 0)
      parts.push(`${minutes}m`);

    return parts.join(", ");
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  FileView {
    id: uptimeFile
    path: "/proc/uptime"
  }

  Timer {
    interval: Config.uptimeRefreshMs
    running: true
    repeat: true
    triggeredOnStart: true

    onTriggered: {
      uptimeFile.reload();

      const uptimeSeconds = Number(uptimeFile.text().split(" ")[0]);
      root.uptime = root.formatUptime(uptimeSeconds);
    }
  }
}
