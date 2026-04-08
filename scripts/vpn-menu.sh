#!/bin/bash
# ==========================================
# File: vpn-menu.sh
# Description: Windscribe rofi manager
# Author: AMOS-fet
# ==========================================

STATUS=$(windscribe-cli status 2>&1)
ICON_GREEN="$HOME/dotfiles/icons/windscribe128-green.png"
ICON_WHITE="$HOME/dotfiles/icons/windscribe128-white.png"
ICON_YELLOW="$HOME/dotfiles/icons/windscribe128-yellow.png"

# ==========================================
# 1. LOGIN STATUS
# ==========================================
if [[ "$STATUS" == *"Logged out"* ]]; then
    kitty -- bash -c "echo '=== WINDSCRIBE LOGIN ==='; windscribe-cli login; read"
    
    # Ricontrolla lo stato dopo il tentativo
    NEW_STATUS=$(windscribe-cli status 2>&1)
    if [[ "$NEW_STATUS" == *"Logged out"* ]]; then
        exit 1
    fi
    exit 0
fi

# ==========================================
# 2. STATUS DISCONNECTED
# ==========================================
if [[ "$STATUS" == *"Connect state: Connected"* ]]; then
    if windscribe-cli disconnect; then
        notify-send -a "Windscribe" -i "$ICON_WHITE" "Windscribe" "You are now disconnected from Windscribe"
    else
        notify-send -a "Windscribe" -i "$ICON_YELLOW" -u critical "Windscribe" "Error disconnecting from Windscribe"
    fi
    pkill -RTMIN+8 waybar
    exit 0
fi

# ==========================================
# 3. STATUS CONNECTED
# ==========================================
LIST_BEST="    Best Location (Automatic)\n"
LIST_FAV=""
LIST_NON_PRO=""
LIST_PRO=""


FAV_SHORTS=" "

FAV_RAW=$(windscribe-cli locations fav | tail -n +1)

while IFS= read -r line; do
    if [[ -z "$line" ]]; then continue; fi
    LIST_FAV+="   $line\n"
    
    SHORT=$(echo "$line" | awk '{print $(NF-1)}')
    FAV_SHORTS+="$SHORT "
done <<< "$FAV_RAW"

LOCATIONS_RAW=$(windscribe-cli locations | tail -n +1)

while IFS= read -r line; do
    if [[ -z "$line" ]]; then continue; fi
    
    SHORT=$(echo "$line" | awk -F ' - ' '{print $2}')
    
    if [[ "$FAV_SHORTS" == *" $SHORT "* ]]; then
        continue
    fi
    
    if [[ "$line" == *"(Pro)"* ]]; then
        LIST_PRO+="   $line\n"
    else
        LIST_NON_PRO+="   $line\n"
    fi
done <<< "$LOCATIONS_RAW"


SORTED_FAV=$(echo -e "$LIST_FAV" | sed '/^$/d' | sort -f)
SORTED_NON_PRO=$(echo -e "$LIST_NON_PRO" | sed '/^$/d' | sort -f)
SORTED_PRO=$(echo -e "$LIST_PRO" | sed '/^$/d' | sort -f)

MENU="   Best Location (Automatic)"

[[ -n "$SORTED_FAV" ]] && MENU="${MENU}\n${SORTED_FAV}"
[[ -n "$SORTED_NON_PRO" ]] && MENU="${MENU}\n${SORTED_NON_PRO}"
[[ -n "$SORTED_PRO" ]] && MENU="${MENU}\n${SORTED_PRO}"

# ==========================================
# 4. ROFI CUSTOM WRAPPER
# ==========================================
VPN_OVERRIDE="
    mainbox { children: [ inputbar, listview ]; }
    inputbar { enabled: true; }
    listview { scrollbar: true; fixed-height: true; }
"

CHOICE=$(echo -e "$MENU" | ~/dotfiles/scripts/rofi-menu-selector.sh -p "Windscribe:" -theme-str "$VPN_OVERRIDE")

if [[ -z "$CHOICE" ]]; then
    exit 0
fi

# ==========================================
# 5. CONNECTION
# ==========================================
if [[ "$CHOICE" == *"Best Location"* ]]; then
    TARGET="best"
else
    TARGET=$(echo "$CHOICE" | awk -F ' - ' '{print $2}')
fi

if ! windscribe-cli connect "$TARGET" > /dev/null 2>&1; then
    notify-send -a "Windscribe" -i "$ICON_YELLOW" -u critical "Windscribe" "Internet connectivity is not available"
    exit 1
fi

NEW_STATUS=$(windscribe-cli status 2>/dev/null)

if [[ "$NEW_STATUS" == *"Connect state: Connected"* ]]; then
    LOC=$(echo "$NEW_STATUS" | grep -i "Connect state: Connected:" | sed 's/.*Connect state: Connected: //' | tr -d '\r\n')
    notify-send -a "Windscribe" -i "$ICON_GREEN" "Windscribe" "You are now connected to Windscribe ($LOC)"
else
    notify-send -a "Windscribe" -i "$ICON_WHITE" -u critical "Windscribe" "Connection error. Please try again."
fi

# ==========================================
# 6. WAYBAR UPDATE
# ==========================================

pkill -RTMIN+8 waybar
