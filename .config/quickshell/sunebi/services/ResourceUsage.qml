pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs

// CPU, RAM and GPU load as shares from 0 to 1, read from procfs and the amdgpu sysfs node
Singleton {
  id: root

  property real cpu: 0
  property real memory: 0
  property real gpu: 0

  // /proc/stat counts ticks since boot, so the load is the share of busy ticks since the previous sample
  property real previousTotalTicks: 0
  property real previousIdleTicks: 0

  function sampleCpu(): void {
    const ticks = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
    // user, nice, system, idle, iowait, irq, softirq, steal; guest time is already inside user
    const total = ticks.slice(0, 8).reduce((sum, value) => sum + value, 0);
    const idle = ticks[3] + ticks[4];
    const totalDelta = total - previousTotalTicks;

    if (previousTotalTicks > 0 && totalDelta > 0)
      cpu = 1 - (idle - previousIdleTicks) / totalDelta;

    previousTotalTicks = total;
    previousIdleTicks = idle;
  }

  function sampleMemory(): void {
    const text = meminfo.text();
    const total = Number(text.match(/MemTotal:\s+(\d+)/)[1]);
    const available = Number(text.match(/MemAvailable:\s+(\d+)/)[1]);
    memory = 1 - available / total;
  }

  Timer {
    running: true
    repeat: true
    triggeredOnStart: true
    interval: Config.resourceRefreshMs

    onTriggered: {
      stat.reload();
      meminfo.reload();
      gpuBusy.reload();
      root.sampleCpu();
      root.sampleMemory();
      root.gpu = Number(gpuBusy.text()) / 100;
    }
  }

  // reload() is asynchronous, without blocking the read right after it would give the previous sample, or nothing at all on the first one
  FileView {
    id: stat
    path: "/proc/stat"
    blockAllReads: true
  }

  FileView {
    id: meminfo
    path: "/proc/meminfo"
    blockAllReads: true
  }

  FileView {
    id: gpuBusy
    path: Config.gpuBusyPath
    blockAllReads: true
  }
}
