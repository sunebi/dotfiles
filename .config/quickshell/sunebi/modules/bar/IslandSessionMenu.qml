pragma ComponentBehavior: Bound

import QtQuick

import qs
import qs.services

// The island's content while it is open to the session menu: the uptime on top, the buttons in a row and the name of the one in focus below
FocusScope {
  id: root

  property bool active: false
  property int focusedIndex: 0

  readonly property var focusedAction: SessionMenu.actions[focusedIndex]
  // The island pads its content by less than the menu needs, this is the rest
  readonly property int verticalMargin: Theme.islandSessionPadding - Theme.islandInset

  function move(step: int): void {
    focusedIndex = Math.max(0, Math.min(SessionMenu.actions.length - 1, focusedIndex + step));
  }

  function isConfirmKey(event: var): bool {
    return event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space;
  }

  onActiveChanged: {
    if (active) {
      focusedIndex = 0;
      forceActiveFocus();
      return;
    }
    // A hold that was still going when the menu closed must not keep its ring
    for (let index = 0; index < buttons.count; index++)
      (buttons.itemAt(index) as SessionButton).release();
  }

  Keys.onLeftPressed: move(-1)
  Keys.onRightPressed: move(1)
  Keys.onEscapePressed: SessionMenu.open = false
  Keys.onPressed: event => {
    const letter = event.text.toLowerCase();
    if (letter === "a" || letter === "ф") {
      move(-1);
    } else if (letter === "d" || letter === "в") {
      move(1);
    } else if (isConfirmKey(event) && !event.isAutoRepeat) {
      (buttons.itemAt(focusedIndex) as SessionButton).press();
    }
  }
  Keys.onReleased: event => {
    if (isConfirmKey(event) && !event.isAutoRepeat)
      (buttons.itemAt(focusedIndex) as SessionButton).release();
  }

  StyledText {
    id: uptime

    anchors.top: parent.top
    anchors.topMargin: root.verticalMargin
    anchors.horizontalCenter: parent.horizontalCenter
    height: Theme.islandSessionLineHeight
    color: Colors.mutedForeground
    font.weight: Font.DemiBold
    verticalAlignment: Text.AlignVCenter
    text: "Up " + DateTime.uptime
  }

  Row {
    anchors.top: uptime.bottom
    anchors.topMargin: Theme.islandSessionRowGap
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Theme.islandSessionButtonGap

    Repeater {
      id: buttons

      model: SessionMenu.actions

      delegate: SessionButton {
        id: button

        required property var modelData
        required property int index

        glyph: modelData.glyph
        hold: modelData.hold
        focused: index === root.focusedIndex

        onEntered: root.focusedIndex = index
        onActivated: SessionMenu.run(modelData)
      }
    }
  }

  StyledText {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.verticalMargin
    anchors.horizontalCenter: parent.horizontalCenter
    height: Theme.islandSessionLineHeight
    color: root.focusedAction.hold ? Colors.destructive : Colors.foreground
    font.weight: Font.DemiBold
    verticalAlignment: Text.AlignVCenter
    // A button that has to be held says so, nothing else tells it from the ones that act at once
    text: root.focusedAction.hold ? "Hold to " + root.focusedAction.label : root.focusedAction.label
  }
}
