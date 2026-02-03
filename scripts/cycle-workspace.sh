#!/bin/bash

# -----------------------------------------------------
# File: cycle-workspace.sh
# Description: Cycles through a fixed number of workspaces
#              Wraps around (e.g., 5 -> 1 and 1 -> 5).
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Configuration
# -----------------------------------------------------

# Total number of workspaces defined in Waybar/Hyprland
TOTAL_WORKSPACES=5

# -----------------------------------------------------
# 2. Get Current State
# -----------------------------------------------------

# Get current workspace ID from the focused monitor using jq
CURRENT=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

# Fallback safety: If hyprctl fails, default to 1
if [[ -z "$CURRENT" || "$CURRENT" == "null" ]]; then
    CURRENT=1
fi

# -----------------------------------------------------
# 3. Calculation Logic
# -----------------------------------------------------

calc_target() {
    local direction=$1

    if [ "$direction" == "next" ]; then
        if [ "$CURRENT" -ge "$TOTAL_WORKSPACES" ]; then
            echo 1
        else
            echo $((CURRENT + 1))
        fi
    elif [ "$direction" == "prev" ]; then
        if [ "$CURRENT" -le 1 ]; then
            echo "$TOTAL_WORKSPACES"
        else
            echo $((CURRENT - 1))
        fi
    fi
}

# -----------------------------------------------------
# 4. Execution
# -----------------------------------------------------

ACTION=$1

case $ACTION in
    next)
        TARGET=$(calc_target "next")
        hyprctl dispatch workspace "$TARGET"
        ;;
    prev)
        TARGET=$(calc_target "prev")
        hyprctl dispatch workspace "$TARGET"
        ;;
    move-next)
        TARGET=$(calc_target "next")
        hyprctl dispatch movetoworkspace "$TARGET"
        ;;
    move-prev)
        TARGET=$(calc_target "prev")
        hyprctl dispatch movetoworkspace "$TARGET"
        ;;
    *)
        echo "Usage: $0 [next|prev|move-next|move-prev]"
        exit 1
        ;;
esac
