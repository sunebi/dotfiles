pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick

// Which tray items stay in the bar and which live in the overflow popup, each group in its own order.
// Kept in the shell state directory so drag and drop choices survive restarts.
Singleton {
  readonly property list<string> pinnedIds: storage.pinnedIds
  readonly property list<string> hiddenIds: storage.hiddenIds

  // Apps seen for the first time are hidden until the user pins them
  readonly property var runningItems: SystemTray.items.values
  onRunningItemsChanged: adoptNewItems()

  // Ids of apps that are not running stay in the lists, so their place is kept for the next start
  readonly property var pinnedItems: itemsFor(pinnedIds)
  readonly property var hiddenItems: itemsFor(hiddenIds)

  function itemsFor(ids: var): var {
    return ids.map(id => runningItems.find(item => item.id === id)).filter(item => item !== undefined);
  }

  function pin(id: string): void {
    storage.pinnedIds = [...pinnedIds.filter(pinnedId => pinnedId !== id), id];
    storage.hiddenIds = hiddenIds.filter(hiddenId => hiddenId !== id);
  }

  function unpin(id: string): void {
    storage.hiddenIds = [...hiddenIds.filter(hiddenId => hiddenId !== id), id];
    storage.pinnedIds = pinnedIds.filter(pinnedId => pinnedId !== id);
  }

  // Dropping an icon on another one swaps them within a group, across groups it takes the target's place and pushes the target on
  function place(id: string, targetId: string): void {
    const pinned = [...pinnedIds];
    const hidden = [...hiddenIds];
    const targetGroup = pinned.includes(targetId) ? pinned : hidden;
    const sourceGroup = pinned.includes(id) ? pinned : hidden;
    const targetIndex = targetGroup.indexOf(targetId);
    const sourceIndex = sourceGroup.indexOf(id);

    if (sourceGroup === targetGroup) {
      [targetGroup[sourceIndex], targetGroup[targetIndex]] = [targetGroup[targetIndex], targetGroup[sourceIndex]];
    } else {
      sourceGroup.splice(sourceIndex, 1);
      targetGroup.splice(targetIndex, 0, id);
    }

    storage.pinnedIds = pinned;
    storage.hiddenIds = hidden;
  }

  function adoptNewItems(): void {
    for (const item of runningItems) {
      if (!pinnedIds.includes(item.id) && !hiddenIds.includes(item.id))
        storage.hiddenIds = [...hiddenIds, item.id];
    }
  }

  FileView {
    path: Quickshell.statePath("tray.json")

    onAdapterUpdated: writeAdapter()
    onLoaded: adoptNewItems()
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound) {
        writeAdapter();
        adoptNewItems();
      }
    }

    adapter: JsonAdapter {
      id: storage

      property list<string> pinnedIds: ["spotify-client", "TelegramDesktop"]
      property list<string> hiddenIds: []
    }
  }
}
