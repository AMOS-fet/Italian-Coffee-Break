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

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

# Compile the list
ENTRIES="$OPT_SHUTDOWN\n$OPT_REBOOT\n$OPT_LOCK\n$OPT_SUSPEND\n$OPT_LOGOUT"

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

SELECTED=$(echo -e "$ENTRIES" | rofi -dmenu \
    -i \
    -config "$ROFI_CONFIG" \
    -p "Theme" \
    -theme-str '
        window { 
            width: 230px; 
            border: 4px;
        }
        mainbox { 
            padding: 3px;          
            children: [ listview ];
        }
        listview { 
            lines: 5; 
            padding: 0px;
            scrollbar: false;
            spacing: 5px;           
        }
        element { 
            orientation: horizontal;
            children: [ element-text ];
            padding: 10px 12px;     
            border-radius: 6px;     
        }
        element-text { 
            expand: true;
            horizontal-align: 0.0;  
            vertical-align: 0.5;
        }
    ')
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
