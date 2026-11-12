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

  // Empty while nothing plays, otherwise the name of the playing app's stream so other apps cannot move the bars
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

  function sourceFor(player: MprisPlayer): string {
    if (!player)
      return "";

    const identity = player.identity.toLowerCase();
    const desktopEntry = (player.desktopEntry ?? "").toLowerCase();
    // Playback streams only have their name until a tracker binds them, their properties are empty
    const stream = Pipewire.nodes.values.find(node => {
      if (!node.isStream || !node.isSink)
        return false;

      const application = node.name.toLowerCase();
      return application !== "" && (application === desktopEntry || identity.includes(application));
    });

    // The default output would also carry voices of calls, so there is no fallback to it
    return stream ? stream.name : "";
  }

  function config(source: string): string {
    return `[general]
bars = ${Config.visualizerBars}
framerate = ${Config.visualizerFramerate}
[input]
method = pipewire
source = ${source}
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
        onRead: line => root.levels = line.split(";").filter(value => value !== "").map(value => Number(value) / 100)
      }

      Component.onDestruction: root.levels = Array(Config.visualizerBars).fill(0)
    }
  }
}
