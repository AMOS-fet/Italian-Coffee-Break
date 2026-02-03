#!/bin/bash

# -----------------------------------------------------
# File: theme-menu.sh
# Description: Rofi menu to select between Light and Dark themes
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables
# -----------------------------------------------------

DOTFILES="$HOME/dotfiles"
SCRIPT_PATH="$DOTFILES/scripts/theme-switch.sh"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

# Icons and Titles
OPT_LIGHT="   Light Mode"
OPT_DARK="   Dark Mode"

# -----------------------------------------------------
# 2. Show Menu
# -----------------------------------------------------

CHOICE=$(echo -e "$OPT_LIGHT\n$OPT_DARK" | rofi -dmenu \
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
            lines: 2; 
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
