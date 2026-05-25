#!/bin/bash

# -----------------------------------------------------
# File: power-profiles.sh
# Description: Manages CPU Frequency, EPP, and RAPL Power Limits.
#              Requires root privileges (sudo) or sudoers rules for cpupower/tee.
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 0. Authentication
# -----------------------------------------------------

if [ ! -t 1 ]; then
    exec kitty --class "sudo-askpass" -T "Power Profile" -e "$0" "$@"
    exit 0
fi

YELLOW='\033[1;33m'
RESET='\033[0m'

if ! sudo -n true 2>/dev/null; then
    clear
    echo -e "${YELLOW}:: Authentication required for system maintenance...${RESET}\n"
    
    if ! sudo -v; then
        notify-send -u critical "Power Profile" "Autenticazione annullata o fallita."
        exit 1
    fi
fi

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# -----------------------------------------------------
# 1. Configuration
# -----------------------------------------------------

# MODE 1: BATTERY SAVER
LOW_EPP="balance_power"
LOW_FREQ_MAX="1400MHz"
LOW_PL1=9000   
LOW_PL2=12000

# MODE 2: BALANCED 
MID_EPP="balance_performance"
MID_FREQ_MAX="1700MHz"
MID_PL1=15000
MID_PL2=20000

# MODE 3: PERFORMANCE
HIGH_EPP="performance"
HIGH_FREQ_MAX="2000MHz" 
HIGH_PL1=25000
HIGH_PL2=45000

# -----------------------------------------------------
# 2. System Paths
# -----------------------------------------------------

EPP_PATH="/sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference"
RAPL_PATH="/sys/class/powercap/intel-rapl/intel-rapl:0"
PL1_FILE="$RAPL_PATH/constraint_0_power_limit_uw"
PL2_FILE="$RAPL_PATH/constraint_1_power_limit_uw"

# -----------------------------------------------------
# 3. Functions
# -----------------------------------------------------

apply_profile() {
    # Arguments: $1=EPP, $2=Freq, $3=PL1(mW), $4=PL2(mW)
    local EPP="$1"
    local FREQ="$2"
    local PL1="$3"
    local PL2="$4"

    echo "--- Applying Profile ---"
    
    # Set Frequency Cap
    if [ "$FREQ" == "MAX" ]; then
        # Reset to hardware maximum
        local MAX_HARDWARE=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
        sudo cpupower frequency-set -u $MAX_HARDWARE > /dev/null
    else
        # Apply custom limit
        sudo cpupower frequency-set -u $FREQ > /dev/null
    fi

    # Set EPP (Behavior)
    echo "EPP: $EPP"
    echo "$EPP" | sudo tee $EPP_PATH > /dev/null

    # Set Power Limits (RAPL)
    local PL1_UW=$(($PL1 * 1000))
    local PL2_UW=$(($PL2 * 1000))

    if [ -f "$PL1_FILE" ]; then
        echo "Wattage: PL1 ${PL1}mW / PL2 ${PL2}mW"
        echo "$PL1_UW" | sudo tee "$PL1_FILE" > /dev/null
        echo "$PL2_UW" | sudo tee "$PL2_FILE" > /dev/null
        # Ensure RAPL is enabled
        echo "1" | sudo tee "$RAPL_PATH/enabled" > /dev/null
    fi
}

# -----------------------------------------------------
# 4. Execution Logic
# -----------------------------------------------------

MODE=$1

case "$MODE" in
    "saver")
        apply_profile "$LOW_EPP" "$LOW_FREQ_MAX" "$LOW_PL1" "$LOW_PL2"
        notify-send -u normal "Power Profile" "   Saver\nMax: $LOW_FREQ_MAX"
        ;;
    "balanced")
        apply_profile "$MID_EPP" "$MID_FREQ_MAX" "$MID_PL1" "$MID_PL2"
        notify-send -u normal "Power Profile" "   Balanced\nMax: $MID_FREQ_MAX"
        ;;
    "performance")
        apply_profile "$HIGH_EPP" "$HIGH_FREQ_MAX" "$HIGH_PL1" "$HIGH_PL2"
        notify-send -u normal "Power Profile" "󰈸  Performance\nMax: $HIGH_FREQ_MAX"
        ;;
    *)
        echo "Usage: $0 [saver|balanced|performance]"
        exit 1
        ;;
esac
