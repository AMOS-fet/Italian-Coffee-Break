#!/bin/bash

# -----------------------------------------------------
# File: update.sh
# Description: Full system update script (Pacman + AUR)
#              Includes cleanup of orphans and cache.
# Author: AMOS-fet
# -----------------------------------------------------

# -----------------------------------------------------
# 1. Colors & Formatting
# -----------------------------------------------------

# Fetch colors from terminal 
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# -----------------------------------------------------
# 2. Preparation
# -----------------------------------------------------

echo -e "${BLUE}${BOLD} --- STARTING SYSTEM UPDATE ---${RESET}"

# --- Sudo Keeper ---
# Ask for password immediately
# Keep the sudo token alive in the background to prevent timeout issues
echo -e "${YELLOW}:: Authentication required for system maintenance...${RESET}"
sudo -v

# Loop to keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# -----------------------------------------------------
# 3. Main Update (Pacman + AUR)
# -----------------------------------------------------

echo -e "${YELLOW}:: Updating repositories and packages...${RESET}"

yay -Syu

if [ $? -eq 0 ]; then
    echo -e "${GREEN}${BOLD} Update successful.${RESET}"
else
    echo -e "${RED}${BOLD} Update failed.${RESET}"
    exit 1
fi

# -----------------------------------------------------
# 4. Cleanup
# -----------------------------------------------------

# --- Remove Orphaned Packages ---
echo -e "\n${YELLOW}${BOLD} --- REMOVING ORPHANED PACKAGES ---${RESET}"
yay -Yc --noconfirm

# --- Clean Pacman Cache ---
echo -e "\n${YELLOW}${BOLD} --- CLEANING PACMAN CACHE ---${RESET}"
if command -v paccache &> /dev/null; then
    sudo paccache -r -k 2
else
    echo -e "${RED}!! 'paccache' not found. Install 'pacman-contrib'.${RESET}"
fi

# --- Clean AUR Cache ---
echo -e "\n${YELLOW}${BOLD} --- CLEANING AUR CACHE ---${RESET}"
yay -Sc --noconfirm

# -----------------------------------------------------
# 5. Status Check & Exit
# -----------------------------------------------------

echo -e "\n${BLUE}${BOLD} --- DISK SPACE STATUS ---${RESET}"
df -h / | grep /

echo -e "\n${GREEN}${BOLD}SYSTEM READY!${RESET}"
read -p "Press [Enter] to close..."
