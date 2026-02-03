#!/bin/bash

# -----------------------------------------------------
# File: check-updates.sh
# Description: Counts updates (Pacman + Yay) for Waybar.
#              Returns 3 lines: Text, Tooltip, CSS Class.
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Calculate Updates
# -----------------------------------------------------

# Count official updates (requires pacman-contrib)
if command -v checkupdates &> /dev/null; then
    OFFICIAL=$(checkupdates 2> /dev/null | wc -l)
else
    OFFICIAL=0
fi

# Count AUR updates (requires yay or paru)
if command -v yay &> /dev/null; then
    AUR=$(yay -Qum 2> /dev/null | wc -l)
else
    AUR=0
fi

# Total count
TOTAL=$((OFFICIAL + AUR))

# -----------------------------------------------------
# 2. Waybar Output
# -----------------------------------------------------


if [ "$TOTAL" -gt 0 ]; then
    # updates-available
    echo "    $TOTAL"
    echo "Updates: $OFFICIAL (Pacman) + $AUR (AUR)"
    echo "updates-available"
else
    # updates-none (System is clean)
    echo "    0"
    echo "System is up to date"
    echo "updates-none"
fi
