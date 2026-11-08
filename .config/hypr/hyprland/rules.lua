hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Pin workspaces to monitors so they do not swap when the connection order changes
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true, persistent = true })

hl.layer_rule({
  name = "vicinae",
  match = { namespace = "vicinae" },
  blur = true,
  ignore_alpha = 0,
  no_anim = true,
})
