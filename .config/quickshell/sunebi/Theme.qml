pragma Singleton

import Quickshell
import QtQuick

import qs

// QML hex colors are #AARRGGBB, so the CSS #RRGGBBAA values with alpha are written reordered
Singleton {
  readonly property color background: Config.darkTheme ? "#0A0A0A" : "#FFFFFF"
  readonly property color foreground: Config.darkTheme ? "#FAFAFA" : "#0A0A0A"
  readonly property color card: Config.darkTheme ? "#171717" : "#FFFFFF"
  readonly property color cardForeground: Config.darkTheme ? "#FAFAFA" : "#0A0A0A"
  readonly property color popover: Config.darkTheme ? "#171717" : "#FFFFFF"
  readonly property color popoverForeground: Config.darkTheme ? "#FAFAFA" : "#0A0A0A"
  readonly property color primary: Config.darkTheme ? "#E5E5E5" : "#171717"
  readonly property color primaryForeground: Config.darkTheme ? "#171717" : "#FAFAFA"
  readonly property color secondary: Config.darkTheme ? "#262626" : "#F5F5F5"
  readonly property color secondaryForeground: Config.darkTheme ? "#FAFAFA" : "#171717"
  readonly property color muted: Config.darkTheme ? "#262626" : "#F5F5F5"
  readonly property color mutedForeground: Config.darkTheme ? "#A1A1A1" : "#737373"
  readonly property color accent: Config.darkTheme ? "#262626" : "#F5F5F5"
  readonly property color accentForeground: Config.darkTheme ? "#FAFAFA" : "#171717"
  readonly property color destructive: Config.darkTheme ? "#FF6467" : "#E7000B"
  readonly property color border: Config.darkTheme ? "#1AFFFFFF" : "#E5E5E5"
  readonly property color input: Config.darkTheme ? "#26FFFFFF" : "#E5E5E5"
  readonly property color ring: Config.darkTheme ? "#737373" : "#A1A1A1"

  readonly property color chart1: "#D4D4D4"
  readonly property color chart2: "#737373"
  readonly property color chart3: "#525252"
  readonly property color chart4: "#404040"
  readonly property color chart5: "#262626"

  readonly property color sidebar: Config.darkTheme ? "#171717" : "#FAFAFA"
  readonly property color sidebarForeground: Config.darkTheme ? "#FAFAFA" : "#0A0A0A"
  readonly property color sidebarPrimary: Config.darkTheme ? "#1447E6" : "#171717"
  readonly property color sidebarPrimaryForeground: "#FAFAFA"
  readonly property color sidebarAccent: Config.darkTheme ? "#262626" : "#F5F5F5"
  readonly property color sidebarAccentForeground: Config.darkTheme ? "#FAFAFA" : "#171717"
  readonly property color sidebarBorder: Config.darkTheme ? "#1AFFFFFF" : "#E5E5E5"
  readonly property color sidebarRing: Config.darkTheme ? "#737373" : "#A1A1A1"

  // 0.625rem
  readonly property int radius: 10

  readonly property int barHeight: 32
  readonly property int barMarginTop: 6
  readonly property int barMarginX: 8
  readonly property int capsulePaddingX: 12
  readonly property int spacing: 8
  readonly property int workspaceSize: 22
  readonly property int workspaceSpacing: 2
  readonly property int trayIconSize: 16
  readonly property int trayPopupHeight: trayIconSize + 2 * spacing
  readonly property int dragThreshold: 4
  // Advance of the widest speaker glyph (three waves) at fontSize and trayFontWeight
  readonly property int volumeIconWidth: 22
  readonly property int fontSize: 13
  readonly property int statusLabelFontSize: 12
  readonly property int trayFontWeight: Font.Medium
  readonly property int indicatorDuration: 250
  readonly property string fontText: "SF Pro Text"
  readonly property string fontDisplay: "SF Pro Display"
}
