#!/bin/bash

# -----------------------------------------------------
# File: install-fonts.sh
# Description: Installs required fonts from AUR
# Author: AMOS-fet
# -----------------------------------------------------

echo "Checking for AUR helper."
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    echo "Error: yay or paru not found."
    exit 1
fi

echo "Using $AUR_HELPER to install fonts."

# 1. Apple Fonts
echo "Installing Apple Fonts family."
$AUR_HELPER -S --needed --noconfirm apple-fonts

# 2. SF Mono Liga 
echo "Installing SF Mono Liga."
$AUR_HELPER -S --needed --noconfirm nerd-fonts-sf-mono-ligatures

# 3. JetBrains Mono Nerd Font
echo "Installing Nerd Fonts."
$AUR_HELPER -S --needed --noconfirm ttf-jetbrains-mono-nerd

echo "Font installation complete! Refreshing font cache."
fc-cache -fv

echo "Done."
