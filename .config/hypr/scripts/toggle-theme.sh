#!/bin/sh
# Portal-aware apps (GTK4, libadwaita, browsers, Qt 6) follow color-scheme, GTK3 only follows gtk-theme
schema=org.gnome.desktop.interface

if [ "$(gsettings get $schema color-scheme)" = "'prefer-dark'" ]; then
  scheme=prefer-light
  theme=Adwaita
else
  scheme=prefer-dark
  theme=Adwaita-dark
fi

gsettings set $schema gtk-theme "$theme"
gsettings set $schema color-scheme "$scheme"
