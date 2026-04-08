#!/bin/bash
# ==========================================
# File: vpn-menu.sh
# Description: Windscribe and Yggdrasil rofi manager
# Author: AMOS-fet
# ==========================================

MENU="󰖂  Windscribe\n󰹩  Yggdrasil"

VPN_OVERRIDE="
    mainbox { children: [ inputbar, listview ]; }
    inputbar { enabled: false; }
    listview { scrollbar: false; lines: 2; fixed-height: true; }
"

CHOICE=$(echo -e "$MENU" | ~/dotfiles/scripts/rofi-menu-selector.sh -p "󱘎  Network:" -theme-str "$VPN_OVERRIDE")

if [[ -z "$CHOICE" ]]; then
    exit 0
fi

if [[ "$CHOICE" == *"Windscribe"* ]]; then
    ~/dotfiles/scripts/vpn-menu.sh
elif [[ "$CHOICE" == *"Yggdrasil"* ]]; then
    ~/dotfiles/scripts/yggdrasil-toggle.sh
fi
