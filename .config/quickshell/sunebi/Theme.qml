pragma Singleton

import Quickshell
import QtQuick

// The sizes and fonts of the shell. The colors come from the chosen theme file through Colors
Singleton {
  // 0.625rem
  readonly property int radius: 10

  readonly property int barHeight: 32
  readonly property int barMarginTop: 6
  readonly property int barMarginX: 8
  readonly property int capsulePaddingX: 12
  readonly property int spacing: 8
  readonly property int workspaceSize: 22
  readonly property int workspaceSpacing: 2
  readonly property int resourceRingSize: 22
  readonly property int resourceRingWidth: 2
  readonly property int resourceGlyphSize: 10
  // The ring follows the load on a spring: the higher the spring the faster it catches up, the lower the damping the longer it swings
  readonly property real resourceSpring: 3
  readonly property real resourceDamping: 0.3
  readonly property int trayIconSize: 16
  readonly property int trayPopupHeight: trayIconSize + 2 * spacing
  readonly property int dragThreshold: 4
  readonly property int islandIdleWidth: 76
  readonly property int islandMediaWidth: 96
  readonly property int islandVolumeWidth: 144
  readonly property int islandWallpaperWidth: 176
  // The island opens into the wallpaper carousel: p-4 around it, gap-3 between the cards, w-32 neighbours and a w-40 selected card, all 16:9
  readonly property int islandPickerPadding: 16
  readonly property int islandPickerGap: 12
  readonly property int islandPickerCardWidth: 128
  readonly property int islandPickerSelectedCardWidth: 160
  readonly property int islandPickerFooterHeight: 16
  readonly property int islandPickerWidth: 2 * islandPickerPadding + 2 * islandPickerCardWidth + islandPickerSelectedCardWidth + 2 * islandPickerGap
  readonly property int islandPickerHeight: 2 * islandPickerPadding + islandPickerSelectedCardWidth * 9 / 16 + islandPickerGap + islandPickerFooterHeight
  // rounded-2xl for the cards, the island a little under rounded-4xl so the corners stay close to the cards' without being concentric
  readonly property int islandExpandedRadius: 28
  readonly property int islandPickerCardRadius: 16
  // The session menu opens the same way: p-5 around it, five size-10 buttons gap-3 apart, the rows gap-4 apart
  readonly property int islandSessionPadding: 20
  readonly property int islandSessionButtonSize: 40
  readonly property int islandSessionButtonGap: 12
  readonly property int islandSessionRowGap: 16
  readonly property int islandSessionLineHeight: 16
  readonly property int islandSessionWidth: 2 * islandSessionPadding + 5 * islandSessionButtonSize + 4 * islandSessionButtonGap
  readonly property int islandSessionHeight: 2 * islandSessionPadding + 2 * islandSessionLineHeight + 2 * islandSessionRowGap + islandSessionButtonSize
  // Above and below the content, the cover is as tall as what is left; the sides need more room because of the rounded ends
  readonly property int islandInset: 6
  readonly property int islandPaddingX: 9
  readonly property int islandTrackHeight: 6
  readonly property int visualizerBarWidth: 3
  readonly property int visualizerBarSpacing: 2
  readonly property int visualizerHeight: 14
  // w-6, wider than the widest speaker glyph (three waves, 22) so every glyph is centered in the same box
  readonly property int volumeIconWidth: 24
  readonly property int fontSize: 13
  readonly property int statusLabelFontSize: 12
  readonly property int trayFontWeight: Font.Medium
  readonly property int indicatorDuration: 250
  readonly property string fontText: "SF Pro Text"
  readonly property string fontDisplay: "SF Pro Display"
}
