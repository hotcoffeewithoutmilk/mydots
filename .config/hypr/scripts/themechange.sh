#!/bin/bash
THEME='Graphite-Dark'
ICONS='Tela-black-dark'
FONT='Inter 10'
CURSOR='Hackneyed-Dark'
CURSOR_SIZE='24'
COLOR='prefer-dark'

SCHEMA='gsettings set org.gnome.desktop.interface'

apply_themes() {
  echo "applying gtk theme: $THEME"
  ${SCHEMA} gtk-theme "$THEME"

  echo "applying icon theme: $ICONS"
  ${SCHEMA} icon-theme "$ICONS"

  echo "applying cursor theme: $CURSOR"
  ${SCHEMA} cursor-theme "$CURSOR"

  echo "setting cursor size: $CURSOR_SIZE"
  ${SCHEMA} cursor-size "$CURSOR_SIZE"

  echo "applying font: $FONT"
  ${SCHEMA} font-name "$FONT"

  echo "setting color: $COLOR"
  ${SCHEMA} color-scheme "$COLOR"

  echo "gsettings applied, might need app restart"

  mkdir -p "$HOME/.config/gtk-3.0" || {
    echo "dir isnt created"
    exit 1
  }

  echo "[Settings]
gtk-theme-name=$THEME
gtk-icon-theme-name=$ICONS
gtk-cursor-theme-name=$CURSOR
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-font-name=$FONT
    
gtk-application-prefer-dark-theme=1
gtk-button-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-menu-images=0
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb" >~/.config/gtk-3.0/settings.ini

  echo "[Settings]
gtk-theme-name=$THEME
gtk-icon-theme-name=$ICONS
gtk-cursor-theme-name=$CURSOR
gtk-cursor-theme-size=$CURSOR_SIZE
gtk-font-name=$FONT

gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
gtk-xft-rgba="rgb"" >~/.gtkrc-2.0

  sed -i "s/^env = HYPRCURSOR_THEME,.*$/env = HYPRCURSOR_THEME,$CURSOR/" $HOME/.config/hypr/hyprland/env.conf || { echo "couldn't update hyprcursor in env.conf"; }

  sed -i "s/^env = XCURSOR_THEME,.*$/env = XCURSOR_THEME,$CURSOR/" $HOME/.config/hypr/hyprland/env.conf || { echo "couldn't update xcursor in env.conf"; }

  sed -i "s/^env = HYPRCURSOR_SIZE,.*$/env = HYPRCURSOR_SIZE,$CURSOR_SIZE/" $HOME/.config/hypr/hyprland/env.conf || { echo "couldn't update hyprcursor size in env.conf"; }

  sed -i "s/^env = XCURSOR_SIZE,.*$/env = XCURSOR_SIZE,$CURSOR_SIZE/" $HOME/.config/hypr/hyprland/env.conf || { echo "couldn't update xcursor size in env.conf"; }
}

apply_themes

exit 0

