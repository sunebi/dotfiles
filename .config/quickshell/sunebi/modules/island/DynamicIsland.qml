pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick

import qs
import qs.components
import qs.services
import qs.services.cursor

// Always a pill that widens with its content, and opens downward into the session menu or one of the carousels while one of them is open: small and empty while idle, wider for the cover and levels of the playing track, widest for the volume for a moment after it changed
Capsule {
  id: root

  // The monitor of the bar this island sits in, the carousel opens only on the one with the focus
  property var monitor: null

  readonly property bool focused: monitor !== null && monitor === Hyprland.focusedMonitor
  readonly property bool sessionVisible: SessionMenu.open && focused
  readonly property bool pickerVisible: Wallpaper.pickerOpen && focused
  readonly property bool cursorVisible: CursorTheme.pickerOpen && focused
  readonly property bool themeVisible: Themes.pickerOpen && focused
  // Any of the four, the bar needs the keyboard as long as it lasts
  readonly property bool expanded: sessionVisible || pickerVisible || cursorVisible || themeVisible
  readonly property bool volumeVisible: !expanded && volumeTimer.running
  readonly property bool wallpaperVisible: !expanded && !volumeVisible && wallpaperTimer.running
  readonly property bool mediaVisible: !expanded && !volumeVisible && !wallpaperVisible && Media.player !== null

  // The sound system reports its first values while the shell starts, those are not changes of the user
  property bool armed: false

  implicitWidth: sessionVisible ? Theme.islandSessionWidth : (pickerVisible || cursorVisible || themeVisible) ? Theme.islandPickerWidth : volumeVisible ? Theme.islandVolumeWidth : wallpaperVisible ? Theme.islandWallpaperWidth : mediaVisible ? Theme.islandMediaWidth : Theme.islandIdleWidth
  implicitHeight: sessionVisible ? Theme.islandSessionHeight : (pickerVisible || cursorVisible || themeVisible) ? Theme.islandPickerHeight : Theme.barHeight
  radius: Math.min(height / 2, Theme.islandExpandedRadius)
  paddingX: Theme.islandPaddingX

  function showVolume(): void {
    if (armed)
      volumeTimer.restart();
  }

  Behavior on implicitWidth {
    NumberAnimation {
      duration: Theme.indicatorDuration
      easing.type: Easing.OutCubic
    }
  }

  Behavior on implicitHeight {
    NumberAnimation {
      duration: Theme.indicatorDuration
      easing.type: Easing.OutCubic
    }
  }

  Timer {
    interval: 1000
    running: true
    onTriggered: root.armed = true
  }

  Timer {
    id: volumeTimer

    interval: Config.volumeHudMs
  }

  Timer {
    id: wallpaperTimer

    interval: Config.wallpaperHudMs
  }

  Connections {
    target: Wallpaper

    function onApplied(): void {
      wallpaperTimer.restart();
    }
  }

  Connections {
    target: Audio

    function onVolumeChanged(): void {
      root.showVolume();
    }

    function onMutedChanged(): void {
      root.showVolume();
    }
  }

  Item {
    implicitWidth: root.implicitWidth - 2 * root.paddingX
    implicitHeight: root.implicitHeight - 2 * Theme.islandInset
    // While the island grows or shrinks the content must not stick out of it
    clip: true

    IslandSessionMenu {
      anchors.fill: parent
      active: root.sessionVisible
      opacity: root.sessionVisible ? 1 : 0
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandCarousel {
      anchors.fill: parent
      active: root.pickerVisible
      opacity: root.pickerVisible ? 1 : 0
      visible: opacity > 0
      model: Wallpaper.model
      startIndex: Wallpaper.indexOfCurrent()
      nameAt: index => Wallpaper.nameAt(index)

      onChosen: index => {
        Wallpaper.apply(Wallpaper.pathAt(index));
        Wallpaper.pickerOpen = false;
      }
      onDismissed: Wallpaper.pickerOpen = false

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandCarousel {
      anchors.fill: parent
      active: root.cursorVisible
      opacity: root.cursorVisible ? 1 : 0
      visible: opacity > 0
      model: CursorTheme.model
      startIndex: CursorTheme.indexOfCurrent()
      nameAt: index => CursorTheme.nameAt(index)
      // An arrow is small, it is shown whole in the middle of its card
      fillMode: Image.PreserveAspectFit
      imagePadding: 16

      onChosen: index => {
        CursorTheme.apply(CursorTheme.nameAt(index));
        CursorTheme.pickerOpen = false;
      }
      onDismissed: CursorTheme.pickerOpen = false

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandCarousel {
      anchors.fill: parent
      active: root.themeVisible
      opacity: root.themeVisible ? 1 : 0
      visible: opacity > 0
      model: Themes.model
      startIndex: Themes.indexOfCurrent()
      nameAt: index => Themes.nameAt(index)
      cardContent: Component {
        ThemeCard {}
      }

      onChosen: index => {
        Themes.apply(Themes.idAt(index));
        Themes.pickerOpen = false;
      }
      onDismissed: Themes.pickerOpen = false

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandMedia {
      anchors.fill: parent
      opacity: root.mediaVisible ? 1 : 0
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandWallpaper {
      anchors.fill: parent
      opacity: root.wallpaperVisible ? 1 : 0
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }

    IslandVolume {
      anchors.fill: parent
      opacity: root.volumeVisible ? 1 : 0
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation {
          duration: Theme.indicatorDuration
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
