#!/bin/bash

# -----------------------------------------------------
# File: apply-neon-light.sh
# Description: Applies Light wallpaper with a "flickering neon" animation
#              Simulates a fluorescent light struggling to turn on.
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

# -----------------------------------------------------
# 2. Functions & Setup
# -----------------------------------------------------

set_img() {
    swww img "$1" --transition-type none
}

swww query || swww-daemon &

# -----------------------------------------------------
# 3. Animation Sequence (Power Up)
# -----------------------------------------------------

# PHASE 0
set_img "$IMG_DARK"
sleep 1.0

# PHASE 1
set_img "$IMG_FLICKER"
sleep 0.03  
set_img "$IMG_DARK"
sleep 0.8   # Pause

# PHASE 2
set_img "$IMG_FLICKER"
sleep 0.04
set_img "$IMG_LIGHT" 
sleep 0.02
set_img "$IMG_DARK"  
sleep 1.2  

# PHASE 3
set_img "$IMG_FLICKER"; sleep 0.02
set_img "$IMG_LIGHT";   sleep 0.03
set_img "$IMG_FLICKER"; sleep 0.02
set_img "$IMG_DARK";    sleep 0.04 
set_img "$IMG_LIGHT";   sleep 0.04
set_img "$IMG_FLICKER"; sleep 0.03
set_img "$IMG_DARK"
sleep 1.5   # Pause

# PHASE 4
set_img "$IMG_FLICKER"
sleep 0.05
set_img "$IMG_LIGHT"
sleep 0.2  
set_img "$IMG_FLICKER"
sleep 0.04 
set_img "$IMG_DARK"
sleep 0.6  

# PHASE 5
set_img "$IMG_FLICKER"
sleep 0.05

swww img "$IMG_LIGHT" --transition-type simple --transition-step 200 --transition-fps 60
