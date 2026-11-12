pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.services

// Always a pill that widens with its content: small and empty while idle, wider for the cover and levels of the playing track, widest for the volume for a moment after it changed
Capsule {
  id: root

  readonly property bool volumeVisible: volumeTimer.running
  readonly property bool mediaVisible: !volumeVisible && Media.player !== null

  // The sound system reports its first values while the shell starts, those are not changes of the user
  property bool armed: false

  implicitWidth: volumeVisible ? Theme.islandVolumeWidth : mediaVisible ? Theme.islandMediaWidth : Theme.islandIdleWidth
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

  Timer {
    interval: 1000
    running: true
    onTriggered: root.armed = true
  }

  Timer {
    id: volumeTimer

    interval: Config.volumeHudMs
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
    implicitHeight: Theme.barHeight - 2 * Theme.islandInset

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
