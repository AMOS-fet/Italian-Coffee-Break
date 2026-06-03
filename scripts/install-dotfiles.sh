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
    "zsh:The Z shell"
    "zsh-autosuggestions:Zsh plugin for history-based suggestions"
    "zsh-syntax-highlighting:Zsh plugin for syntax highlighting"
    "librewolf-bin:Community-mantained fork of firefox"
    "awww:Wallpaper Utility"
    "mako:Notification Daemon"
    "rofi:Application Launcher"
    "starship:Cross-shell Prompt"
    "waybar:Status Bar for Wayland"
    "micro:Intuitive Terminal Editor"
    "fastfetch:System information tool"
    "networkmanager:Standard Network Manager"
    "bulletty:Pretty feed reader for the terminal"
    "btop:A monitor of resources"
)


FONTS=(
    "apple-fonts:Apple San Francisco Fonts (AUR)"
    "nerd-fonts-sf-mono-ligatures:SF Mono with Ligatures (AUR)"
    "ttf-jetbrains-mono-nerd:JetBrains Mono Nerd Font"
)


THEMES=(
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
    
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local box_width=60 
    local margin_left=$(( (term_width - box_width) / 2 ))
    
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

    if [ "$pkg" == "colloid-gtk-manual" ]; then
        if [ -d "$HOME/.themes/Colloid-Dark" ] || [ -d "$HOME/.local/share/themes/Colloid-Dark" ]; then
            return 0
        else
            return 1
        fi
    fi

    if [ "$pkg" == "whitesur-icon-manual" ]; then
        if [ -d "$HOME/.local/share/icons/WhiteSur" ] || [ -d "$HOME/.icons/WhiteSur" ]; then
            return 0
        else
            return 1
        fi
    fi

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
        cd "$temp_dir" || return
        echo "   -> Running installer..."
        ./install.sh -t default -c dark light --tweaks rimless
        
        echo "  Colloid Theme installed."
        cd - > /dev/null || return
        rm -rf "$temp_dir"
    else
        echo "  Error cloning Colloid repo."
    fi
}

_install_whitesur_manual() {
    echo "  Cloning WhiteSur Icon Theme..."
    local temp_dir="/tmp/whitesur-icon-theme"
    rm -rf "$temp_dir"
    
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git "$temp_dir" --depth 1
    
    if [ -d "$temp_dir" ]; then
        cd "$temp_dir" || return
        echo "   -> Running installer..."
        ./install.sh
        
        echo "  WhiteSur Icons installed."
        cd - > /dev/null || return
        rm -rf "$temp_dir"
    else
        echo "  Error cloning WhiteSur repo."
    fi
}


_install() {
    local pkg=$1

    if [ "$pkg" == "colloid-gtk-manual" ]; then
        _install_colloid_manual
        return
    fi

    if [ "$pkg" == "whitesur-icon-manual" ]; then
        _install_whitesur_manual
        return
    fi

    if _is_installed "$pkg"; then
        echo "  $pkg is already installed."
    else
        echo "  Installing $pkg..."
        yay -S --noconfirm "$pkg"
    fi
}


_stow() {
    local pkg=$1
    
    if [ "$pkg" == "colloid-gtk-manual" ] || [ "$pkg" == "whitesur-icon-manual" ] || [[ "$pkg" == *"fonts"* ]] || [ "$pkg" == "zsh-autosuggestions" ] || [ "$pkg" == "zsh-syntax-highlighting" ]; then
        return
    fi

    local stow_folder="$pkg"
    
    case "$pkg" in
        "hyprland")       stow_folder="hypr" ;;
        "librewolf-bin")  stow_folder="librewolf" ;;
        "zsh")            stow_folder="shell" ;;
    esac

    local source_path="$DOTFILES_DIR/$stow_folder"
    
    if [ -d "$source_path" ]; then
        echo "Stowing configuration for $stow_folder..."
        
        local target_config="$HOME/.config/$stow_folder"
        
        if [ "$pkg" == "zsh" ]; then
            target_config="$HOME/.zshrc"
        fi
        
        if [ -e "$target_config" ]; then
            if [ -L "$target_config" ]; then
                echo "  -> $stow_folder is already a link"
            else
                rm -rf "$target_config"
            fi
        fi

        stow -d "$DOTFILES_DIR" -t "$HOME" -R "$stow_folder"
    else
        echo "  No config for $stow_folder (skipping stow)"
    fi
}


_protect_local_files() {
    local pkg=$1
    
    if [ "$pkg" == "colloid-gtk-manual" ] || [ "$pkg" == "whitesur-icon-manual" ] || [[ "$pkg" == *"fonts"* ]] || [ "$pkg" == "zsh-autosuggestions" ] || [ "$pkg" == "zsh-syntax-highlighting" ]; then
        return
    fi

    local stow_folder="$pkg"
    
    case "$pkg" in
        "hyprland")       stow_folder="hypr" ;;
        "librewolf-bin")  stow_folder="librewolf" ;;
        "zsh")            stow_folder="shell" ;;
    esac

    local target_dir="$DOTFILES_DIR/$stow_folder"

    if [ -d "$target_dir" ]; then
        cd "$DOTFILES_DIR" || return
        
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            
            local clean_file="${file#./}"
            
            if git ls-files --error-unmatch "$clean_file" &> /dev/null; then
                git update-index --skip-worktree "$clean_file"
                gum style --foreground 245 "  -> Protected from Git: $clean_file"
            fi
        done < <(find "$stow_folder" -type f -name "*local*")
        
        cd - > /dev/null || return
    fi
}


_build_colored_list() {
    local -n arr=$1
    local -n out_arr=$2
    local -n out_pre=$3
    
    local C_GREEN=$'\033[32m'
    local C_WHITE=$'\033[37m'
    local C_RESET=$'\033[0m'
    
    out_pre=""
    out_arr=()
    
    for item in "${arr[@]}"; do
        local pkg="${item%%:*}"
        if _is_installed "$pkg"; then
            local formatted_item="${C_GREEN}${item}${C_RESET}"
            if [ -z "$out_pre" ]; then
                out_pre="$formatted_item"
            else
                out_pre="$out_pre,$formatted_item"
            fi
        else
            local formatted_item="${C_WHITE}${item}${C_RESET}"
        fi
        out_arr+=("$formatted_item")
    done
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

COLOR_BLUE="#448385"

clear

_print_centered_header "DOTFILES MANAGER" "Step 1/3: Select Software"

echo "  Scanning system for installed software..."
_build_colored_list PACKAGES COLORED_PACKAGES PRE_SELECTED_PKGS

SELECTED_PACKAGES_RAW=$(gum choose --no-limit --height 12 \
    --cursor=" " \
    --cursor.foreground="$COLOR_BLUE" \
    --selected.foreground="$COLOR_BLUE" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_PKGS" \
    "${COLORED_PACKAGES[@]}")

clear


_print_centered_header "TYPOGRAPHY" "Step 2/3: Select Fonts"

echo "  Scanning system for installed fonts..."
_build_colored_list FONTS COLORED_FONTS PRE_SELECTED_FONTS

SELECTED_FONTS_RAW=$(gum choose --no-limit --height 10 \
    --cursor=" " \
    --cursor.foreground="$COLOR_BLUE" \
    --selected.foreground="$COLOR_BLUE" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_FONTS" \
    "${COLORED_FONTS[@]}")

clear


_print_centered_header "LOOK & FEEL" "Step 3/3: Select Themes, Icons & Cursors"

echo "  Scanning system for installed themes..."
_build_colored_list THEMES COLORED_THEMES PRE_SELECTED_THEMES

SELECTED_THEMES_RAW=$(gum choose --no-limit --height 10 \
    --cursor=" " \
    --cursor.foreground="$COLOR_BLUE" \
    --selected.foreground="$COLOR_BLUE" \
    --header="SPACE to select/deselect, ENTER to confirm" \
    --selected="$PRE_SELECTED_THEMES" \
    "${COLORED_THEMES[@]}")

clear

SELECTED_PACKAGES=$(echo "$SELECTED_PACKAGES_RAW" | sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g')
SELECTED_FONTS=$(echo "$SELECTED_FONTS_RAW" | sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g')
SELECTED_THEMES=$(echo "$SELECTED_THEMES_RAW" | sed $'s/\e\\[[0-9;:]*[a-zA-Z]//g')

if [ -z "$SELECTED_PACKAGES" ] && [ -z "$SELECTED_FONTS" ] && [ -z "$SELECTED_THEMES" ]; then
    echo "No items selected. Exiting."
    exit 0
fi

_print_centered_header "SUMMARY" "Ready to install"

gum style --foreground 212 "Selected Software:"
if [ ! -z "$SELECTED_PACKAGES" ]; then
    echo "$SELECTED_PACKAGES" | awk -F: '{print "  - \033[36m" $1 "\033[0m (" $2 ")"}'
else
    echo "  (None)"
fi

echo ""
gum style --foreground 212 "Selected Fonts:"
if [ ! -z "$SELECTED_FONTS" ]; then
    echo "$SELECTED_FONTS" | awk -F: '{print "  - \033[36m" $1 "\033[0m (" $2 ")"}'
else
    echo "  (None)"
fi

echo ""
gum style --foreground 212 "Selected Themes:"
if [ ! -z "$SELECTED_THEMES" ]; then
    echo "$SELECTED_THEMES" | awk -F: '{print "  - \033[36m" $1 "\033[0m (" $2 ")"}'
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
    _protect_local_files "$pkg"
    
    echo ""
done

bash "$HOME/dotfiles/scripts/theme-switch.sh" dark orange

_print_centered_header "SUCCESS" "All tasks completed successfully!"
