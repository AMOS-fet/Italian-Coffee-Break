#!/bin/bash
# ==========================================
# File: vpn-status.sh
# Description: Windscribe and Yggdrasil status fetcher
# Author: AMOS-fet
# ==========================================


# ==========================================
# 1. WINDSCRIBE
# ==========================================
STATUS=$(windscribe-cli status 2>/dev/null)

DATA_RAW=$(echo "$STATUS" | grep -i "^Data usage:" | sed 's/^Data usage: //' | tr -d '\r\n')
[[ -z "$DATA_RAW" ]] && DATA_RAW="Unavailable"

WS_DATA_USAGE=$(echo "$DATA_RAW" | awk '{
    if ($0 ~ /Unlimited|Unavailable/) { print $0 } else {
        used = $1; unit1 = $2; total = $4; unit2 = $5;
        if (unit1 == "MB" && unit2 == "GB") { used = used / 1024 }
        else if (unit1 == "KB" && unit2 == "GB") { used = used / 1048576 }
        remaining = total - used
        if (remaining < 0) remaining = 0
        printf "%.2f %s / %.2f %s", remaining, unit2, total, unit2
    }
}')

if [[ "$STATUS" == *"Connect state: Connected"* ]]; then
    WS_SERVER=$(echo "$STATUS" | grep -i "Connect state: Connected:" | sed 's/.*Connect state: Connected: //' | tr -d '\r\n')
    [[ -z "$WS_SERVER" ]] && WS_SERVER="Unknown"
    
    WS_PROTOCOL=$(echo "$STATUS" | grep -i "^Protocol:" | sed 's/^Protocol: //' | tr -d '\r\n')
    [[ -z "$WS_PROTOCOL" ]] && WS_PROTOCOL="Auto"
    
    WS_IS_CONNECTED=true
    WS_TOOLTIP="󰖂   Windscribe: Connected\\n󰒋   Server: ${WS_SERVER}\\n   Protocol: ${WS_PROTOCOL}\\n󰓅   Data: ${WS_DATA_USAGE}"
else
    WS_IS_CONNECTED=false
    WS_TOOLTIP="󰖂   Windscribe: Disconnected\\n󰓅   Data: ${WS_DATA_USAGE}"
fi

# ==========================================
# 2. YGGDRASIL
# ==========================================
if systemctl is-active --quiet yggdrasil; then
    YGG_IS_CONNECTED=true
    
    YGG_IP=$(ip -6 addr show | grep -i "inet6 2" | awk '{print $2}' | cut -d/ -f1 | head -n 1)
    [[ -z "$YGG_IP" ]] && YGG_IP="Unknown"
    
    YGG_RAW=$(sudo yggdrasilctl getPeers | grep "│" | tail -n +2 | head -n 1)
        
    if [[ -n "$YGG_RAW" ]]; then
        YGG_NODE=$(echo "$YGG_RAW" | awk -F '│' '{print $2}' | xargs)
        YGG_PEER_IP=$(echo "$YGG_RAW" | awk -F '│' '{print $5}' | xargs)
    else
        YGG_NODE="No active peers"
        YGG_PEER_IP="Unknown"
    fi
    
    YGG_TOOLTIP="󱑽   Yggdrasil: Connected\\n󰒋   Node: ${YGG_NODE}\\n󰩟   My IPv6: ${YGG_IP}\\n󰩟   Peer IP: ${YGG_PEER_IP}"
else
    YGG_IS_CONNECTED=false
    YGG_TOOLTIP="󱑽   Yggdrasil: Disconnected"
fi

# ==========================================
# 3. JSON WAYBAR
# ==========================================
SEPARATOR="\\n━━━━━━━━━━━━━━━━━━━━━━━━\\n"
FULL_TOOLTIP="${WS_TOOLTIP}${SEPARATOR}${YGG_TOOLTIP}"

if $WS_IS_CONNECTED || $YGG_IS_CONNECTED; then
    CLASS="connected"
    TEXT="󰖂"
else
    CLASS="disconnected"
    TEXT="󰖂"
fi

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$TEXT" "$CLASS" "$FULL_TOOLTIP"
