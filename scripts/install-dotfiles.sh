#!/bin/bash

# -----------------------------------------------------
# File: install-dotfiles.sh
# Description: Script to install and sync system dotfiles
# Author: AMOS-fet
# -----------------------------------------------------


# -----------------------------------------------------
# 1. Configuration
# -----------------------------------------------------

DOTFILES_DIR="$HOME/dotfiles"


PACKAGES=(
    "hyprland:Tiling Window Manager"
    "kitty:GPU Accelerated Terminal"
    "hyprpaper:Wallpaper Utility"
    "mako:Notification Daemon"
    "rofi:Application Launcher"
    "starship:Cross-shell Prompt"
    "waybar:Status Bar for Wayland"
    "micro:Intuitive Terminal Editor"
)


FONTS=(
    "apple-fonts:Apple San Francisco Fonts (AUR)"
    "nerd-fonts-sf-mono-ligatures:SF Mono with Ligatures (AUR)"
    "ttf-jetbrains-mono-nerd:JetBrains Mono Nerd Font"
)


THEMES=(
    # Note: These use special keywords intercepted by the script
    "colloid-gtk-manual:Colloid GTK Theme (Dark & Light only)"
    "whitesur-icon-manual:WhiteSur Icon Theme"
    "phinger-cursors:Phinger Cursor Theme"
)

# -----------------------------------------------------
# 2. Functions
# -----------------------------------------------------

_print_centered_header() {
    local title="$1"
    local subtitle="$2"
    
    local term_width=$(tput cols)
    local box_width=60 
    local margin_left=$(( (term_width - box_width) / 2 ))
    
    # Safety check for small screens
    if [ "$margin_left" -lt 0 ]; then margin_left=0; fi
    
    echo ""
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --padding "2 4" \
        --margin "1 $margin_left" \
        "$title" "$subtitle"
    echo ""
}


_is_installed() {
    local pkg=$1

    # Check for Colloid Manual
    if [ "$pkg" == "colloid-gtk-manual" ]; then
        if [ -d "$HOME/.themes/Colloid-Dark" ] || [ -d "$HOME/.local/share/themes/Colloid-Dark" ]; then
            return 0
        else
            return 1
        fi
    fi

    # Check for WhiteSur Manual
    if [ "$pkg" == "whitesur-icon-manual" ]; then
        if [ -d "$HOME/.local/share/icons/WhiteSur" ] || [ -d "$HOME/.icons/WhiteSur" ]; then
            return 0
        else
            return 1
        fi
    fi

    # Standard check via pacman
    if pacman -Qi "$pkg" &> /dev/null; then
        return 0 # True
    else
        return 1 # False
    fi
}


_install_colloid_manual() {
    echo "  Cloning Colloid GTK Theme (Dark/Light only)..."
    local temp_dir="/tmp/colloid-gtk-theme"
    rm -rf "$temp_dir"
    
    git clone https://github.com/vinceliuice/Colloid-gtk-theme.git "$temp_dir" --depth 1
    
    if [ -d "$temp_dir" ]; then
        cd "$temp_dir" || exit
        echo "   -> Running installer..."
        ./install.sh -t default -c dark light --tweaks rimless
        
        echo "  Colloid Theme installed."
        rm -rf "$temp_dir"
    else
        echo "❌ Error cloning Colloid repo."
    fi
}

_install_whitesur_manual() {
    echo "  Cloning WhiteSur Icon Theme..."
    local temp_dir="/tmp/whitesur-icon-theme"
    rm -rf "$temp_dir"
    
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git "$temp_dir" --depth 1
    
    if [ -d "$temp_dir" ]; then
        cd "$temp_dir" || exit
        echo "   -> Running installer..."
        ./install.sh
        
        echo "  WhiteSur Icons installed."
        rm -rf "$temp_dir"
    else
        echo "❌ Error cloning WhiteSur repo."
    fi
}


_install() {
    local pkg=$1

    # Intercept Manual Installs
    if [ "$pkg" == "colloid-gtk-manual" ]; then
        _install_colloid_manual
        return
    fi

    if [ "$pkg" == "whitesur-icon-manual" ]; then
        _install_whitesur_manual
        return
    fi

    # Standard Install
    if _is_installed "$pkg"; then
        echo "  $pkg is already installed."
    else
        echo "  Installing $pkg..."
        yay -S --noconfirm "$pkg"
    fi
}


_stow() {
    local pkg=$1
    
   
    if [ "$pkg" == "colloid-gtk-manual" ] || [ "$pkg" == "whitesur-icon-manual" ]; then
        return
    fi

    local target="$DOTFILES_DIR/$pkg"
    
    if [ -d "$target" ]; then
        echo "Stowing configuration for $pkg..."
        # -R (Restow) is safer than -S as it refreshes links
        stow -d "$DOTFILES_DIR" -t "$HOME" -R "$pkg" 2>/dev/null
    else
        echo "  No dotfiles config for $pkg (Skipping stow)"
    fi
}


_build_preselected_list() {
    local -n arr=$1
    local pre_selected=""
    for item in "${arr[@]}"; do
        pkg_name="${item%%:*}"
        if _is_installed "$pkg_name"; then
            if [ -z "$pre_selected" ]; then
                pre_selected="$item"
            else
                pre_selected="$pre_selected,$item"
            fi
        fi
    done
    echo "$pre_selected"
}

# -----------------------------------------------------
# 3. Main
# -----------------------------------------------------

if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is not installed. Please install it first (sudo pacman -S gum)."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: 'git' is not installed. Please install it first."
    exit 1
fi

clear


_print_centered_header "DOTFILES MANAGER" "Step 1/3: Select Software"

echo " Scanning system for installed software..."
PRE_SELECTED_PKGS=$(_build_preselected_list PACKAGES)

SELECTED_PACKAGES=$(gum choose --no-limit --height 10 \
    --cursor=" " \
    --cursor.foreground="212" \
    --selected.foreground="212" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_PKGS" \
    "${PACKAGES[@]}")


clear
_print_centered_header "TYPOGRAPHY" "Step 2/3: Select Fonts"

echo " Scanning system for installed fonts..."
PRE_SELECTED_FONTS=$(_build_preselected_list FONTS)

SELECTED_FONTS=$(gum choose --no-limit --height 10 \
    --cursor=" " \
    --cursor.foreground="212" \
    --selected.foreground="212" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_FONTS" \
    "${FONTS[@]}")


clear
_print_centered_header "LOOK & FEEL" "Step 3/3: Select Themes, Icons & Cursors"

echo " Scanning system for installed themes..."
PRE_SELECTED_THEMES=$(_build_preselected_list THEMES)

SELECTED_THEMES=$(gum choose --no-limit --height 10 \
    --cursor=" " \
    --cursor.foreground="212" \
    --selected.foreground="212" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_THEMES" \
    "${THEMES[@]}")


clear

if [ -z "$SELECTED_PACKAGES" ] && [ -z "$SELECTED_FONTS" ] && [ -z "$SELECTED_THEMES" ]; then
    echo "No items selected. Exiting."
    exit 0
fi

_print_centered_header "SUMMARY" "Ready to install"

gum style --foreground 212 "Selected Software:"
if [ ! -z "$SELECTED_PACKAGES" ]; then
    echo "$SELECTED_PACKAGES" | awk -F: '{print "  - " $1 " (" $2 ")"}'
else
    echo "  (None)"
fi

echo ""
gum style --foreground 212 "Selected Fonts:"
if [ ! -z "$SELECTED_FONTS" ]; then
    echo "$SELECTED_FONTS" | awk -F: '{print "  - " $1 " (" $2 ")"}'
else
    echo "  (None)"
fi

echo ""
gum style --foreground 212 "Selected Themes:"
if [ ! -z "$SELECTED_THEMES" ]; then
    echo "$SELECTED_THEMES" | awk -F: '{print "  - " $1 " (" $2 ")"}'
else
    echo "  (None)"
fi
echo ""

gum confirm "Proceed with installation?" || exit 0

echo ""
gum style --foreground 212 "Starting installation process..."


echo "󰓦 Updating package databases..."
yay -Sy


ALL_SELECTIONS="$SELECTED_PACKAGES
$SELECTED_FONTS
$SELECTED_THEMES"


IFS=$'\n'
for line in $ALL_SELECTIONS; do
    [ -z "$line" ] && continue

    pkg="${line%%:*}"
    
    gum style --foreground 99 " Processing: $pkg"
    
    _install "$pkg"
    _stow "$pkg"
    
    echo ""
done

_print_centered_header "SUCCESS" "All tasks completed successfully!"
