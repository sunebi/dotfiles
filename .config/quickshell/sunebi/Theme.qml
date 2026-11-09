pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property color background: "#0a0a0a"
  readonly property color foreground: "#fafafa"
  readonly property color mutedForeground: "#a3a3a3"
  readonly property color activeBackground: "#262626"

  readonly property int barHeight: 32
  readonly property int barMarginTop: 6
  readonly property int barMarginX: 8
  readonly property int capsulePaddingX: 12
  readonly property int spacing: 8
  readonly property int workspaceSize: 22
  readonly property int trayIconSize: 16
  readonly property int fontSize: 13
  readonly property string fontText: "SF Pro Text"
  readonly property string fontDisplay: "SF Pro Display"
}
