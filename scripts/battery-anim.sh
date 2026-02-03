#!/bin/bash

# -----------------------------------------------------
# File: battery-anim.sh
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Configuration
# -----------------------------------------------------

BAT=$(ls /sys/class/power_supply | grep -E 'BAT[0-9]+' | head -n 1)

# Safety check: Exit if no battery is found
if [ -z "$BAT" ]; then
    exit 0
fi

# --- Icons ---
# Charging: 0-9 
ICONS_CHARGING=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")

# Discharging: 0-10
ICONS_DISCHARGING=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

# Animation frame counter
ANIM_INDEX=0

# -----------------------------------------------------
# 2. Main Loop
# -----------------------------------------------------

while true; do
    STATUS=$(cat /sys/class/power_supply/$BAT/status)
    CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity)

    if [ "$STATUS" == "Charging" ]; then
        
        ICON="${ICONS_CHARGING[$ANIM_INDEX]}"
        CSS_CLASS="charging"
        
        ANIM_INDEX=$(( (ANIM_INDEX + 1) % 10 ))
        
    else
        IDX=$((CAPACITY / 10))
        
        if [ "$IDX" -gt 10 ]; then IDX=10; fi
        
        ICON="${ICONS_DISCHARGING[$IDX]}"
        
        if [ "$CAPACITY" -le 15 ]; then
            CSS_CLASS="critical"
        else
            CSS_CLASS="discharging"
        fi
    fi

    # --- Output ---
    echo "{\"text\": \"<span size='12pt' rise='-500'>$ICON</span> <b>$CAPACITY%</b>\", \"tooltip\": \"Status: $STATUS ($CAPACITY%)\", \"class\": \"$CSS_CLASS\"}"
    sleep 0.5
done
