pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
  // Appearance
  readonly property bool darkTheme: true

  // Volume
  readonly property real volumeMax: 1
  readonly property real volumeStep: 0.02
  readonly property real fineVolumeThreshold: 0.1
  readonly property real fineVolumeStep: 0.01
  // Below the first threshold the volume icon shows one wave, from the second one it shows three
  readonly property real lowVolumeThreshold: 0.33
  readonly property real highVolumeThreshold: 0.85

  // Media
  // Player identities that win over the other players while they play, after them the player that started last
  readonly property list<string> mediaPlayerPriority: ["Spotify"]
  readonly property int visualizerBars: 6
  readonly property int visualizerFramerate: 24
  readonly property int volumeHudMs: 1500

  // Date and time
  readonly property string timeFormat: "hh:mm"
  readonly property string trayClockFormat: "ddd MMM d  hh:mm"
  readonly property string shortDateFormat: "dd/MM"
  readonly property string dateFormat: "dd/MM/yyyy"
  readonly property string longDateFormat: "dddd, dd/MM"
  readonly property string collapsedCalendarDateFormat: "dddd, MMMM dd"
  readonly property int uptimeRefreshMs: 3000

  // Matches the 1-9 workspace keybinds in hypr, there is no key for a tenth
  readonly property int workspaceCount: 9

  // Hyprland also reports workspaces with ids outside this range (e.g. lock screen: 2147483647 - N)
  readonly property int lastRegularWorkspaceId: 100
}
