pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Mpris
import QtQml.Models
import QtQuick

import qs

Singleton {
  id: root

  property MprisPlayer lastStarted: null

  readonly property list<var> playing: Mpris.players.values.filter(candidate => isActive(candidate))
  // The playing player the island shows, null while nothing plays
  readonly property MprisPlayer player: preferred() ?? (isActive(lastStarted) ? lastStarted : null) ?? playing[0] ?? null

  // Spotify serves ads as tracks of their own, they are not music to show
  function isAd(candidate: MprisPlayer): bool {
    return String(candidate.metadata["mpris:trackid"] ?? "").includes("/com/spotify/ad/");
  }

  function isActive(candidate: MprisPlayer): bool {
    return candidate !== null && candidate.isPlaying && !isAd(candidate);
  }

  // A configured identity wins over the others even if one of them started later
  function preferred(): MprisPlayer {
    for (const identity of Config.mediaPlayerPriority) {
      const match = playing.find(candidate => candidate.identity === identity);
      if (match)
        return match;
    }
    return null;
  }

  Instantiator {
    model: Mpris.players

    Connections {
      required property MprisPlayer modelData

      target: modelData

      Component.onCompleted: {
        if (modelData.isPlaying)
          root.lastStarted = modelData;
      }

      function onIsPlayingChanged(): void {
        if (modelData.isPlaying)
          root.lastStarted = modelData;
      }
    }
  }
}
