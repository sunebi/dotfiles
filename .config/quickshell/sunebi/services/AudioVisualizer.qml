pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import QtQml.Models
import QtQuick

import qs

Singleton {
  id: root

  // One value from 0 to 1 per bar, all zero while nothing plays
  property var levels: Array(Config.visualizerBars).fill(0)

  // Empty while nothing plays, otherwise the serial of the playing app's stream so other apps cannot move the bars
  readonly property string wanted: sourceFor(Media.player)
  // Follows wanted at once, but keeps cava alive through the short gap between tracks instead of restarting it
  property string source: wanted

  onWantedChanged: {
    if (wanted !== "") {
      stopTimer.stop();
      source = wanted;
    } else {
      stopTimer.restart();
    }
  }

  // The slow average of every bar, cava boosts some bands more than others and a fixed shape would follow that tilt instead of the music
  property var averages: Array(Config.visualizerBars).fill(0.5)

  // Every bar is measured against its own average so the bands stay balanced, the cosine window then gives the hump of Apple's visualizer and a bar falls slower than it rises so the motion does not flicker
  function shape(values: var): var {
    const center = (values.length - 1) / 2;
    averages = values.map((value, index) => averages[index] * 0.97 + value * 0.03);
    return values.map((value, index) => {
      const relative = Math.min(1, value / Math.max(averages[index] * 1.7, 0.2));
      const level = Math.pow(relative, 1.3) * (0.7 + 0.3 * Math.cos((index - center) * Math.PI / values.length));
      return Math.max(level, (levels[index] ?? 0) * 0.82);
    });
  }

  // The playback streams, they have only their name until a tracker binds them
  readonly property var streams: Pipewire.nodes.values.filter(node => node.isStream && node.isSink)

  function serialOf(node: PwNode): int {
    return Number(node.properties["object.serial"] ?? 0);
  }

  // The serial of the stream to read, empty when the player has none. Several streams can carry the same app name: a browser opens one for every tab that has played a sound
  function sourceFor(player: MprisPlayer): string {
    if (!player)
      return "";

    const identity = player.identity.toLowerCase();
    const desktopEntry = (player.desktopEntry ?? "").toLowerCase();
    const candidates = streams.filter(node => {
      const application = node.name.toLowerCase();
      return application !== "" && (application === desktopEntry || identity.includes(application));
    });
    // The tab of the playing page names its stream after the page, which the player reports as its title
    const title = player.trackTitle ?? "";
    const named = title !== "" ? candidates.filter(node => (node.properties["media.name"] ?? "").includes(title)) : [];
    const pool = named.length > 0 ? named : candidates;
    if (pool.length === 0)
      return "";

    // A stream that carries sound is attached to a driver, the leftovers of a page that was paused and played again are idle and have none. Of what is left the newest one wins. The name is only a fallback until the tracker has delivered the serial
    const running = pool.filter(node => node.properties["node.driver-id"] !== undefined);
    const live = running.length > 0 ? running : pool;
    const newest = live.reduce((best, node) => serialOf(node) > serialOf(best) ? node : best);
    return String(newest.properties["object.serial"] ?? newest.name);
  }

  PwObjectTracker {
    objects: root.streams
  }

  function config(source: string): string {
    return `[general]
bars = ${Config.visualizerBars}
framerate = ${Config.visualizerFramerate}
autosens = 1
sensitivity = 150
[input]
method = pipewire
source = ${source}
[smoothing]
noise_reduction = 25
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
frame_delimiter = 10
`;
  }

  Timer {
    id: stopTimer

    interval: 3000
    onTriggered: root.source = ""
  }

  // A new model value replaces the cava process with one on the new source, an empty model stops it
  Instantiator {
    model: root.source !== "" ? [root.source] : []

    Process {
      required property string modelData

      running: true
      // cava reads its config from stdin, the heredoc is that stdin and exec keeps cava the only process to stop
      command: ["sh", "-c", `exec cava -p /dev/stdin <<'CAVA'\n${root.config(modelData)}CAVA`]

      stdout: SplitParser {
        onRead: line => root.levels = root.shape(line.split(";").filter(value => value !== "").map(value => Number(value) / 100))
      }

      Component.onDestruction: root.levels = Array(Config.visualizerBars).fill(0)
    }
  }
}
