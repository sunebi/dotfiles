hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 1,
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
  },

  decoration = {
    rounding = 16,
    rounding_power = 3.0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 22,
      render_power = 3,
      color = 0x55000000,
    },
    blur = {
      enabled = false,
      size = 0,
      passes = 0,
      vibrancy = 0,
    },
  },

  animations = {
    enabled = true,
  },
})

hl.config({
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },
})

hl.config({
  layers = {
    allow_new_top_layers_over_existing_fullscreen = true,
  },
})
