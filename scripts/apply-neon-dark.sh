#!/bin/bash

# -----------------------------------------------------
# File: apply-neon-dark.sh
# Description: Applies Dark wallpaper with a "flickering neon" animation
#              Simulates a dying light bulb switching to darkness.
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables
# -----------------------------------------------------

DOTFILES="$HOME/dotfiles"
WALLPAPER_DIR="$DOTFILES/wallpapers"

# Image Paths
IMG_DARK="$WALLPAPER_DIR/wallpaper2_dark.png"
IMG_FLICKER="$WALLPAPER_DIR/wallpaper2_flicker.png"
IMG_LIGHT="$WALLPAPER_DIR/wallpaper2_light.png"

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-1

# -----------------------------------------------------
# 2. Functions & Setup
# -----------------------------------------------------

set_img() {
    /usr/bin/awww img "$1" --transition-type none
}

/usr/bin/awww query || /usr/bin/awww-daemon &

# -----------------------------------------------------
# 3. Animation Sequence (Power Down)
# -----------------------------------------------------

# PHASE 0
set_img "$IMG_LIGHT"
sleep 1.0

# PHASE 1
set_img "$IMG_FLICKER"
sleep 0.03
set_img "$IMG_LIGHT"
sleep 0.8   # Pause

# PHASE 2
set_img "$IMG_DARK"
sleep 0.04
set_img "$IMG_FLICKER"
sleep 0.02
set_img "$IMG_LIGHT"
sleep 1.2   # Pause

# PHASE 3
set_img "$IMG_FLICKER"; sleep 0.02
set_img "$IMG_DARK";    sleep 0.03
set_img "$IMG_FLICKER"; sleep 0.02
set_img "$IMG_LIGHT";   sleep 0.05
set_img "$IMG_DARK";    sleep 0.02
set_img "$IMG_LIGHT";   sleep 0.04
set_img "$IMG_FLICKER"; sleep 0.03

# PHASE 4
set_img "$IMG_DARK"
sleep 1.5   # Pause

set_img "$IMG_FLICKER"
sleep 0.05
set_img "$IMG_LIGHT"
sleep 0.1  
set_img "$IMG_FLICKER"
sleep 0.04
set_img "$IMG_DARK" 

# PHASE 5
awww img "$IMG_DARK" --transition-type simple --transition-step 200 --transition-fps 60
