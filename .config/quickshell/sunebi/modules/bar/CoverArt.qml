import QtQuick

import qs

// Holds the previous cover until the next one has loaded, so a slow connection never shows the empty background between two tracks
Item {
  id: root

  property url source
  // Stacking order of the cover that came last
  property int stack: 0

  component Layer: Image {
    id: layer

    function reveal(): void {
      root.stack += 1;
      z = root.stack;
      fade.restart();
    }

    anchors.fill: parent
    asynchronous: true
    fillMode: Image.PreserveAspectCrop
    mipmap: true
    // The decoder scales while it reads, wallpapers are far bigger than the preview and would otherwise take long to appear
    sourceSize.height: height * 2
    opacity: 0

    NumberAnimation {
      id: fade

      target: layer
      property: "opacity"
      from: 0
      to: 1
      duration: Theme.indicatorDuration
      easing.type: Easing.OutCubic
    }
  }

  onSourceChanged: {
    // The layer that is not on top loads the new cover
    const loading = a.z > b.z ? b : a;
    loading.source = source;
    if (source.toString() === "") {
      a.opacity = 0;
      b.opacity = 0;
    }
  }

  Layer {
    id: a

    onStatusChanged: if (status === Image.Ready && source === root.source)
      reveal()
  }

  Layer {
    id: b

    onStatusChanged: if (status === Image.Ready && source === root.source)
      reveal()
  }
}
