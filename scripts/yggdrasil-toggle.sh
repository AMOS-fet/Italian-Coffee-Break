#!/bin/bash
# ==========================================
# File: yggrasil-toggle.sh
# Description: Yggdrasil service toggle switch
# Author: AMOS-fet
# ==========================================

if systemctl is-active --quiet yggdrasil; then
    if sudo systemctl stop yggdrasil; then
        notify-send -a "Yggdrasil" -i network-wireless-disconnected "Yggdrasil" "You are now disconnected from Yggdrasil"
    else
        notify-send -a "Yggdrasil" -i dialog-error -u critical "Yggdrasil" "Error disconnecting from Yggdrasil"
    fi
else
    if sudo systemctl start yggdrasil; then
        notify-send -a "Yggdrasil" -i network-wireless-connected "Yggdrasil" "You are now connected to Yggdrasil"
    else
        notify-send -a "Yggdrasil" -i dialog-error -u critical "Yggdrasil" "Error connecting to Yggdrasil"
    fi
fi

pkill -RTMIN+8 waybar
