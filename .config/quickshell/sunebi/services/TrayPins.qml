pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Tray items listed here stay in the bar in this order, the rest live in the overflow popup.
// Kept in the shell state directory so drag and drop choices survive restarts.
Singleton {
  readonly property list<string> pinnedIds: storage.pinnedIds

  function isPinned(id: string): bool {
    return pinnedIds.includes(id);
  }

  function pin(id: string): void {
    if (!isPinned(id))
      storage.pinnedIds = [...pinnedIds, id];
  }

  // Dropping an icon on another one swaps them, an icon coming from the popup takes the target's place and pushes it right
  function place(id: string, targetId: string): void {
    const ids = [...pinnedIds];
    const targetIndex = ids.indexOf(targetId);
    const currentIndex = ids.indexOf(id);
    if (currentIndex < 0)
      ids.splice(targetIndex, 0, id);
    else
      [ids[currentIndex], ids[targetIndex]] = [ids[targetIndex], ids[currentIndex]];
    storage.pinnedIds = ids;
  }

  function unpin(id: string): void {
    storage.pinnedIds = pinnedIds.filter(pinnedId => pinnedId !== id);
  }

  FileView {
    path: Quickshell.statePath("tray.json")

    onAdapterUpdated: writeAdapter()
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound)
        writeAdapter();
    }

    adapter: JsonAdapter {
      id: storage

      property list<string> pinnedIds: ["spotify-client", "TelegramDesktop"]
    }
  }
}
