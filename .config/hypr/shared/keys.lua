return {
  terminal = { "SUPER + T", "SUPER + Return" },
  fileManager = "SUPER + E",
  browser = "SUPER + W",
  editor = "SUPER + C",
  volumeMixer = "SUPER + CTRL + V",
  clipboard = "SUPER + V",
  launcher = "SUPER + Space",
  exit = "SUPER + M",
  sessionMenu = "CTRL + ALT + Delete",

  closeWindow = "SUPER + Q",
  toggleFloat = "SUPER + ALT + Space",
  togglePseudo = "SUPER + P",
  toggleSplit = "SUPER + J",
  moveWindow = "SUPER + mouse:272",
  resizeWindow = "SUPER + mouse:273",

  focusLeft = "SUPER + left",
  focusRight = "SUPER + right",
  focusUp = "SUPER + up",
  focusDown = "SUPER + down",

  -- Modifiers only: binds.lua appends the workspace number
  workspaceFocus = "SUPER",
  workspaceMove = "SUPER + SHIFT",
  workspaceNext = "SUPER + mouse_up",
  workspacePrev = "SUPER + mouse_down",
  scratchpad = "SUPER + S",

  screenshot = { "SUPER + SHIFT + S", "Print" },
  colorPicker = "SUPER + SHIFT + C",
  dictation = "SUPER + O",

  wallpaperPicker = "SUPER + CTRL + T",
  wallpaperRandom = "SUPER + CTRL + ALT + T",
  themePicker = "SUPER + CTRL + P",
  -- Three modifiers keep a stray press from flashing a light theme at night; no ALT, because ALT + SHIFT switches the layout
  themeToggle = "SUPER + CTRL + SHIFT + D",

  volumeUp = "XF86AudioRaiseVolume",
  volumeDown = "XF86AudioLowerVolume",
  volumeMute = "XF86AudioMute",
  micMute = "XF86AudioMicMute",
  brightnessUp = "XF86MonBrightnessUp",
  brightnessDown = "XF86MonBrightnessDown",

  mediaNext = "XF86AudioNext",
  mediaPrev = "XF86AudioPrev",
  mediaToggle = { "XF86AudioPlay", "XF86AudioPause" },
}
