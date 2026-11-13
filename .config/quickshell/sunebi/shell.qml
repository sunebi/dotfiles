//@ pragma UseQApplication

import Quickshell

import qs.modules.bar

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
