#!/bin/bash

# -----------------------------------------------------
# File: power-profile-selector.sh
# Description: Wofi menu to select CPU power governor
#              (Saver, Balanced, Performance).
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables
# -----------------------------------------------------

DOTFILES="$HOME/dotfiles"
SCRIPT_PATH="$DOTFILES/scripts/power-profiles.sh"

# Menu Options
OPT_SAVER="   Saver (1.3GHz)"
OPT_BALANCED="󰖌   Balanced (1.7GHz)"
OPT_PERF="󰈸   Performance (2.0GHz)"

# Window Geometry
ROW_HEIGHT=34
OFFSET=0

# Compile list
ENTRIES="$OPT_SAVER\n$OPT_BALANCED\n$OPT_PERF"

# Calculate dynamic height
LINE_COUNT=$(echo -e "$ENTRIES" | wc -l)
TOTAL_HEIGHT=$(( (LINE_COUNT * ROW_HEIGHT) + OFFSET ))

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

CHOICE=$(echo -e "$ENTRIES" | wofi --show dmenu \
    --prompt "Power Profile" \
    --sort-order=default \
    --cache-file /dev/null \
    --width 250 \
    --height $TOTAL_HEIGHT \
    --lines $LINE_COUNT \
    --location center \
    --style "$HOME/.config/wofi/style.css" \
    --hide-search \
    --hide-scroll)

# -----------------------------------------------------
# 3. Execute Action
# -----------------------------------------------------

case "$CHOICE" in
    "$OPT_SAVER")
        "$SCRIPT_PATH" saver
        ;;
    "$OPT_BALANCED")
        "$SCRIPT_PATH" balanced
        ;;
    "$OPT_PERF")
        "$SCRIPT_PATH" performance
        ;;
esac
