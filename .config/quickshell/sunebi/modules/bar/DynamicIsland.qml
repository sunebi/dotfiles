pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick

import qs
import qs.services

// Always a pill that widens with its content, and opens downward into the session menu or the wallpaper carousel while one of them is open: small and empty while idle, wider for the cover and levels of the playing track, widest for the volume for a moment after it changed
Capsule {
  id: root

  // The monitor of the bar this island sits in, the carousel opens only on the one with the focus
  property var monitor: null

  readonly property bool focused: monitor !== null && monitor === Hyprland.focusedMonitor
  readonly property bool sessionVisible: SessionMenu.open && focused
  readonly property bool pickerVisible: Wallpaper.pickerOpen && focused
  // Either of the two, the bar needs the keyboard and a click outside has to close them
  readonly property bool expanded: sessionVisible || pickerVisible
  readonly property bool volumeVisible: !expanded && volumeTimer.running
  readonly property bool wallpaperVisible: !expanded && !volumeVisible && wallpaperTimer.running
  readonly property bool mediaVisible: !expanded && !volumeVisible && !wallpaperVisible && Media.player !== null

  // The sound system reports its first values while the shell starts, those are not changes of the user
  property bool armed: false

  implicitWidth: sessionVisible ? Theme.islandSessionWidth : pickerVisible ? Theme.islandPickerWidth : volumeVisible ? Theme.islandVolumeWidth : wallpaperVisible ? Theme.islandWallpaperWidth : mediaVisible ? Theme.islandMediaWidth : Theme.islandIdleWidth
  implicitHeight: sessionVisible ? Theme.islandSessionHeight : pickerVisible ? Theme.islandPickerHeight : Theme.barHeight
  radius: Math.min(height / 2, Theme.islandExpandedRadius)
  paddingX: Theme.islandPaddingX

  function close(): void {
    SessionMenu.open = false;
    Wallpaper.pickerOpen = false;
  }

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

    IslandWallpaperPicker {
      anchors.fill: parent
      active: root.pickerVisible
      opacity: root.pickerVisible ? 1 : 0
      visible: opacity > 0

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
