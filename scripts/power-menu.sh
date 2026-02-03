#!/bin/bash

# -----------------------------------------------------
# File: power-menu.sh
# Description: Session management menu (Shutdown, Reboot, Lock, etc.)
#              Uses Wofi for selection.
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables & Options
# -----------------------------------------------------

# Options with Icons
OPT_SHUTDOWN="   Shutdown"
OPT_REBOOT="   Reboot"
OPT_LOCK="   Lock"
OPT_SUSPEND="   Suspend"
OPT_LOGOUT="   Logout"

# Window geometry
ROW_HEIGHT=34
OFFSET=0

# Compile the list
ENTRIES="$OPT_SHUTDOWN\n$OPT_REBOOT\n$OPT_LOCK\n$OPT_SUSPEND\n$OPT_LOGOUT"

# Calculate total height based on line count
LINE_COUNT=$(echo -e "$ENTRIES" | wc -l)
TOTAL_HEIGHT=$(( (LINE_COUNT * ROW_HEIGHT) + OFFSET ))

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

# --name wofi-power: Useful for CSS styling customization
SELECTED=$(echo -e "$ENTRIES" | wofi --show dmenu \
    --prompt "Power Menu" \
    --sort-order=default \
    --cache-file=/dev/null \
    --width=250 \
    --height=$TOTAL_HEIGHT \
    --lines=$LINE_COUNT \
    --location center \
    --style "$HOME/.config/wofi/style.css" \
    -b \
    -j \
    )
#  
# -----------------------------------------------------
# 3. Execute Action
# -----------------------------------------------------

case "$SELECTED" in
    "$OPT_SHUTDOWN")
        systemctl poweroff
        ;;
    "$OPT_REBOOT")
        systemctl reboot
        ;;
    "$OPT_LOCK")
        # Check if hyprlock is running before launching
        if ! pidof hyprlock > /dev/null; then
            hyprlock
        fi
        ;;
    "$OPT_SUSPEND")
        systemctl suspend
        ;;
    "$OPT_LOGOUT")
        hyprctl dispatch exit
        ;;
esac
