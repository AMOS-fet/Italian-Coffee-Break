#!/bin/bash

# -----------------------------------------------------
# Script: rofi-selector.sh
# Desc: Rofi dynamic menu wrapper
# Usage: echo -e "Opt1\nOpt2" | ./rofi-selector.sh
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Input
# -----------------------------------------------------

INPUT_DATA=$(cat)

if [[ -z "$INPUT_DATA" ]]; then
    exit 1
fi

# -----------------------------------------------------
# 2. Geometry
# -----------------------------------------------------

LINE_COUNT=$(echo "$INPUT_DATA" | grep -cve '^\s*$')

MAX_LINES=10

if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
    DISPLAY_LINES=$MAX_LINES
else
    DISPLAY_LINES=$LINE_COUNT
fi

MAX_CHARS=$(echo "$INPUT_DATA" | wc -L)

WIDTH_PX=$(( (MAX_CHARS * 11) + 00 ))

if [ "$WIDTH_PX" -lt 200 ]; then
    WIDTH_PX=200
fi

if [ "$WIDTH_PX" -gt 200 ]; then
    WIDTH_PX=450
fi

# -----------------------------------------------------
# 3. Rofi config override (Il tuo default invisibile)
# -----------------------------------------------------
ROFI_OVERRIDE="
    window { 
        width: ${WIDTH_PX}px; 
    }
    mainbox { 
        children: [ listview ]; 
    }
    inputbar {
        enabled: false; 
    }
    listview { 
        lines: ${DISPLAY_LINES}; 
        scrollbar: false; 
        fixed-height: false; 
    }
    element { 
        orientation: horizontal; 
        children: [ element-text ]; 
    }
    element-text { 
        expand: true; 
        horizontal-align: 0.0; 
        vertical-align: 0.5; 
    }
"

# -----------------------------------------------------
# 4. Menu exec
# -----------------------------------------------------
echo "$INPUT_DATA" | rofi -dmenu \
    -i \
    -markup-rows \
    -config "$HOME/.config/rofi/config.rasi" \
    -theme-str "$ROFI_OVERRIDE" "$@"
