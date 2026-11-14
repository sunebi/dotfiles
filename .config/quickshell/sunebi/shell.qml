//@ pragma UseQApplication

import Quickshell

import qs.modules.bar
import qs.modules.island

ShellRoot {
  Variants {
    model: Quickshell.screens

    Bar {}
  }

  Variants {
    model: Quickshell.screens

    IslandDismissLayer {}
  }
}
