pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
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

  // What the media keys steer: the island's player, or else the one that played last so a paused track can be resumed
  readonly property MprisPlayer controlled: player ?? lastStarted ?? Mpris.players.values[0] ?? null

  // Spotify serves ads as tracks of their own, they are not music to show. Browsers expose nothing that tells a YouTube ad apart, so those cannot be filtered
  function isAd(candidate: MprisPlayer): bool {
    return String(candidate.metadata["mpris:trackid"] ?? "").includes("/ad/") || String(candidate.metadata["xesam:url"] ?? "").includes("spotify:ad");
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

  // The media keys of Hyprland call these, so no separate tool like playerctl has to be installed and they act on the same player as the island
  IpcHandler {
    target: "media"

    function toggle(): void {
      root.controlled?.togglePlaying();
    }

    function next(): void {
      root.controlled?.next();
    }

    function previous(): void {
      root.controlled?.previous();
    }
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
