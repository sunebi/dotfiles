pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import qs.services.cursor
import qs.services.themes
import qs.services.wallpaper

Singleton {
  id: root

  // The island on the screen with the focus is open to the session menu while this is set
  property bool open: false

  // The glyphs are SF Symbols private use characters of SF Pro Text: moon.fill, rectangle.portrait.and.arrow.right, lock.fill, arrow.trianglehead.2.clockwise.rotate.90 and power
  // Only what restarts or switches off the machine has to be held, everything else can be taken back by the user
  readonly property var actions: [
    {
      label: "Sleep",
      glyph: "\u{1001BA}",
      hold: false,
      command: ["systemctl", "suspend"]
    },
    {
      label: "Log Out",
      glyph: "\u{100EF5}",
      hold: false,
      command: ["sh", "-c", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"]
    },
    {
      label: "Lock",
      glyph: "\u{1003A1}",
      hold: false,
      command: ["sh", "-c", "command -v hyprlock >/dev/null 2>&1 && hyprlock || loginctl lock-session"]
    },
    {
      label: "Reboot",
      glyph: "\u{1028FC}",
      hold: true,
      command: ["systemctl", "reboot"]
    },
    {
      label: "Shut Down",
      glyph: "\u{1001A8}",
      hold: true,
      command: ["systemctl", "poweroff"]
    }
  ]

  function run(action: var): void {
    open = false;
    Quickshell.execDetached(action.command);
  }

  IpcHandler {
    target: "session"

    function toggle(): void {
      Wallpaper.pickerOpen = false;
      CursorTheme.pickerOpen = false;
      Themes.pickerOpen = false;
      root.open = !root.open;
    }
  }
}
