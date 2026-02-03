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
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

# Menu Options
OPT_SAVER="   Saver (1.3GHz)"
OPT_BALANCED="󰖌   Balanced (1.7GHz)"
OPT_PERF="󰈸   Performance (2.0GHz)"

# Compile list
ENTRIES="$OPT_SAVER\n$OPT_BALANCED\n$OPT_PERF"

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

CHOICE=$(echo -e "$ENTRIES" | rofi -dmenu \
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
            lines: 3; 
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
