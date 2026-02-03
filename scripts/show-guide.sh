#!/bin/bash

CLASS_NAME="floating_guide"
GUIDE_FILE="$HOME/dotfiles/wiki/wiki.md"

if pgrep -f "$CLASS_NAME"; then
    pkill -f "$CLASS_NAME"
else
    kitty --class "$CLASS_NAME" --title "Guide" -e glow -p "$GUIDE_FILE"
fi
