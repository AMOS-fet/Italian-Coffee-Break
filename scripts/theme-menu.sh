#!/bin/bash

# -----------------------------------------------------
# File: theme-menu.sh
# Description: Wofi menu to select between Light and Dark themes
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables
# -----------------------------------------------------

DOTFILES="$HOME/dotfiles"
SCRIPT_PATH="$DOTFILES/scripts/theme-switch.sh"

# Icons and Titles
OPT_LIGHT="   Light Mode"
OPT_DARK="   Dark Mode"

# Window dimensions
ROW_HEIGHT=34
OFFSET=0
TOTAL_HEIGHT=$(( (2 * ROW_HEIGHT) + OFFSET ))

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

CHOICE=$(echo -e "$OPT_LIGHT\n$OPT_DARK" | wofi --show dmenu \
    --prompt "Select Theme" \
    --cache-file /dev/null \
    --height $TOTAL_HEIGHT \
    --width 250 \
    --lines 2 \
    --location center \
    --style "$HOME/.config/wofi/style.css" \
    -b \
    -j)

# -----------------------------------------------------
# 3. Execute Switch
# -----------------------------------------------------

case "$CHOICE" in
    "$OPT_LIGHT")
        notify-send "Theme" "Switching to Light Mode..." -i weather-clear
        "$SCRIPT_PATH" light 
        ;;
    "$OPT_DARK")
        notify-send "Theme" "Switching to Dark Mode..." -i weather-clear-night
        "$SCRIPT_PATH" dark
        ;;
esac
