pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs.services
import qs.services.themes

// The colors of the chosen theme for the system color scheme, the names are the keys of the theme files (shadcn tokens). apply() writes them, so a theme file that is edited while the shell runs shows at once
Singleton {
  id: root

  property color background: "transparent"
  property color foreground: "transparent"
  property color card: "transparent"
  property color cardForeground: "transparent"
  property color popover: "transparent"
  property color popoverForeground: "transparent"
  property color primary: "transparent"
  property color primaryForeground: "transparent"
  property color secondary: "transparent"
  property color secondaryForeground: "transparent"
  property color muted: "transparent"
  property color mutedForeground: "transparent"
  property color accent: "transparent"
  property color accentForeground: "transparent"
  property color destructive: "transparent"
  property color border: "transparent"
  property color input: "transparent"
  property color ring: "transparent"

  function apply(): void {
    const tokens = Themes.tokensFor(JSON.parse(file.text()));
    for (const name of Object.keys(tokens))
      root[name] = tokens[name];
  }

  Component.onCompleted: apply()

  Connections {
    target: ColorScheme

    function onDarkChanged(): void {
      root.apply();
    }
  }

  // Read before the first frame, so the shell never starts in a blank theme
  FileView {
    id: file

    path: Quickshell.shellPath("themes/" + Themes.current + ".json")
    blockLoading: true
    watchChanges: true

    onFileChanged: reload()
    onLoaded: root.apply()
  }
}
