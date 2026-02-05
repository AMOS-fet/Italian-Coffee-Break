#!/bin/bash

# -----------------------------------------------------
# File: theme-menu.sh
# Description: Theme and accent color selector
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Variables
# -----------------------------------------------------

DOTFILES="$HOME/dotfiles"
SCRIPT_PATH="$DOTFILES/scripts/theme-switch.sh"
SELECTOR="$DOTFILES/scripts/rofi-menu-selector.sh"

# Icons and Titles
OPT_LIGHT="   Light Mode"
OPT_DARK="   Dark Mode"

RED="<span color='#F94835'></span>   Red"
GREEN="<span color='#B7B827'></span>   Green"
YELLOW="<span color='#F9BB31'></span>   Yellow"
BLUE="<span color='#83A497'></span>   Blue"
PURPLE="<span color='#D184CC'></span>   Purple"
AQUA="<span color='#8EBE7A'></span>   Aqua"
ORANGE="<span color='#FE7C0D'></span>   Orange"

COLOR_ENTRIES="$RED\n$GREEN\n$YELLOW\n$BLUE\n$PURPLE\n$AQUA\n$ORANGE"

# -----------------------------------------------------
# 2. Show Menus
# -----------------------------------------------------

THEME=$(echo -e "$OPT_LIGHT\n$OPT_DARK" | "$SELECTOR")

if [ -z "$THEME" ]; then
    exit 0
fi

ACCENT=$(echo -e "$COLOR_ENTRIES" | "$SELECTOR")

if [ -z "$ACCENT" ]; then
    exit 0
fi

# -----------------------------------------------------
# 3. Override Variables
# -----------------------------------------------------

case "$THEME" in
    *"Light"*) MODE="light" ;;
    *"Dark"*)  MODE="dark" ;;
esac

case "$ACCENT" in
    *"Red"*)    ACCENT_CODE="red" ;;
    *"Green"*)  ACCENT_CODE="green" ;;
    *"Yellow"*) ACCENT_CODE="yellow" ;;
    *"Blue"*)   ACCENT_CODE="blue" ;;
    *"Purple"*) ACCENT_CODE="purple" ;;
    *"Aqua"*)   ACCENT_CODE="aqua" ;;
    *"Orange"*) ACCENT_CODE="orange" ;; 
esac

#notify-send "Applying: $MODE theme ($ACCENT_CODE)..." -i preferences-desktop-theme

"$SCRIPT_PATH" "$MODE" "$ACCENT_CODE"
