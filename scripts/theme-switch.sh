#!/bin/bash

# -----------------------------------------------------
# File: theme-switch.sh
# Description: Switches system-wide theme (Dark/Light)
#              Manages symlinks, GTK, Browsers, and reload triggers.
# Author: AMOS-fet
# -----------------------------------------------------

export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH

MODE=$1
ACCENT=$2
DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
PALETTE_FILE="$DOTFILES/scripts/palette.conf"

# -----------------------------------------------------
# 1. Validate data
# -----------------------------------------------------

if [[ ! -f "$PALETTE_FILE" ]]; then
    echo " Error: Palette file not found at $PALETTE_FILE"
    exit 1
fi

source "$PALETTE_FILE"

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo " Error: Specify mode [dark|light]"
    exit 1
fi

if [[ -z "$ACCENT" ]]; then
    echo " Error: Accent argument missing."
    exit 1
fi

# -----------------------------------------------------
# 2. Select accent color brightness
# -----------------------------------------------------

if [ "$MODE" == "dark" ]; then
    CANDIDATE="${ACCENT}_br"
else
    CANDIDATE="${ACCENT}"
fi

if [[ -n "${!CANDIDATE}" ]]; then
    TARGET_VAR="$CANDIDATE"
else
    TARGET_VAR="$ACCENT"
fi

FINAL_ACCENT_HEX="${!TARGET_VAR}"

# -----------------------------------------------------
# 3. Variables
# -----------------------------------------------------

if [ "$MODE" == "dark" ]; then
    # --- DARK MODE ---
    T_BG="$black"           # Main background
    T_BG_ALT="$black_hd"    # UI Elements background (bars, inputs)
    T_FG="$white"           # Main text / Foreground
    T_FG_DIM="$white_sf"    # Secondary text / Dimmed
    T_BORDER="$black_sf"    # Inactive borders
else
    # --- LIGHT MODE ---
    T_BG="$white"           # Main background
    T_BG_ALT="$white_hd"    # UI Elements background
    T_FG="$black"           # Main text / Foreground
    T_FG_DIM="$black_sf"    # Secondary text / Dimmed
    T_BORDER="$white_sf"    # Inactive borders
fi

# HEX to RGB
to_rgb() {
    echo "${1:1}"
}

# -----------------------------------------------------
# 4. Application: HYPRLAND
# -----------------------------------------------------

if command -v Hyprland &> /dev/null; then

    TEMPLATE_FILE="$DOTFILES/hypr/.config/hypr/colors-${MODE}.conf"
    TARGET_FILE="$CONFIG_DIR/hypr/colors.conf"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo " Error: Template '$TEMPLATE_FILE' not found!"
        exit 1
    fi    

    BASE_ACCENT="${ACCENT%_br}"
    VAR_NORMAL="\$${BASE_ACCENT%_br}"   # es. "red"
    VAR_BRIGHT="\$${BASE_ACCENT}_br"    # es. "red_br"
    
    if [ "$MODE" == "dark" ]; then
        NEW_BORDER="$VAR_BRIGHT $VAR_NORMAL 45deg"
    else
        NEW_BORDER="$VAR_NORMAL $VAR_BRIGHT 45deg"
    fi

    rm -f "$TARGET_FILE"
    cp -f "$TEMPLATE_FILE" "$TARGET_FILE"
    sed -i "s|^\$active_border.*|\$active_border = $NEW_BORDER|" "$TARGET_FILE"

    hyprctl reload 1> /dev/null
fi

# -----------------------------------------------------
# 5. Application: ROFI
# -----------------------------------------------------
if command -v rofi &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/rofi/.config/rofi/config-${MODE}.rasi"
    TARGET_FILE="$CONFIG_DIR/rofi/config.rasi"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo " Error: Template '$TEMPLATE_FILE' not found!"
        exit 1
    fi

    rm -f "$TARGET_FILE"
    cp "$TEMPLATE_FILE" "$TARGET_FILE"
    sed -i "s/border-col:.*;/border-col: $FINAL_ACCENT_HEX;/" "$TARGET_FILE"
fi

# -----------------------------------------------------
# 6. Application: KITTY
# -----------------------------------------------------
if command -v kitty &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/kitty/.config/kitty/theme-${MODE}.conf"
    TARGET_FILE="$CONFIG_DIR/kitty/theme.conf"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo " Error: Template '$TEMPLATE_FILE' not found!"
        exit 1
    fi
    
    BASE_ACCENT="${ACCENT%_br}"    
    VAR_NORMAL="${BASE_ACCENT}"     
    VAR_BRIGHT="${BASE_ACCENT}_br"  
    
    HEX_ACTIVE="${!VAR_BRIGHT}"    
    HEX_INACTIVE="${!VAR_NORMAL}"  

    if [[ -z "$HEX_INACTIVE" ]]; then HEX_INACTIVE="$HEX_ACTIVE"; fi
    
    rm -f "$TARGET_FILE"
    cp "$TEMPLATE_FILE" "$TARGET_FILE"

    sed -i "s/^selection_background.*/selection_background  $HEX_ACTIVE/" "$TARGET_FILE"
    sed -i "s/^active_tab_background.*/active_tab_background $HEX_ACTIVE/" "$TARGET_FILE"
    sed -i "s/^inactive_tab_background.*/inactive_tab_background $HEX_INACTIVE/" "$TARGET_FILE"

    killall -SIGUSR1 kitty 2>/dev/null
fi

# -----------------------------------------------------
# 7. Application: STARSHIP 
# -----------------------------------------------------
if command -v starship &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/starship/.config/starship-${MODE}.toml"
    TARGET_FILE="$CONFIG_DIR/starship.toml"

    BASE_ACCENT="${ACCENT%_br}"

    COLORS_ARRAY=("red" "orange" "yellow" "green" "aqua" "blue" "purple")

    
    START_INDEX=-1
    for i in "${!COLORS_ARRAY[@]}"; do
        if [[ "${COLORS_ARRAY[$i]}" == "$BASE_ACCENT" ]]; then
            START_INDEX=$i
            break
        fi
    done

    if [[ $START_INDEX -eq -1 ]]; then
        exit 1
    fi
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        cp "$TEMPLATE_FILE" "$TARGET_FILE"
        sed -i "/^\[os\]/,/^\[/ s/bg:color_[a-zA-Z0-9_]*/bg:color_${COLORS_ARRAY[$START_INDEX]}/" "$TARGET_FILE"            
        sed -i "/^\[username\]/,/^\[/ s/bg:color_[a-zA-Z0-9_]*/bg:color_${COLORS_ARRAY[$START_INDEX]}/" "$TARGET_FILE"
        
        sed -i "s/\[\](color_[a-zA-Z0-9_]*)\\\\/[](color_${COLORS_ARRAY[$START_INDEX]})\\\\/" "$TARGET_FILE"
        sed -i "/\\\$username/,/\\\$directory/ s/\(\[\](bg:color_[a-zA-Z0-9_]* \)fg:color_[a-zA-Z0-9_]*/\1fg:color_${COLORS_ARRAY[$START_INDEX]}/" "$TARGET_FILE" 
        sed -i "/\\\$username/,/\\\$directory/ s/\[\](bg:color_[a-zA-Z0-9_]*/[](bg:color_${COLORS_ARRAY[($START_INDEX + 1) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"

        sed -i "/^\[directory\]/,/^\[/ s/bg:color_[a-zA-Z0-9_]*/bg:color_${COLORS_ARRAY[($START_INDEX + 1) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"
        sed -i "/\\\$directory/,/\\\$git_branch/ s/\(\[\](bg:color_[a-zA-Z0-9_]* \)fg:color_[a-zA-Z0-9_]*/\1fg:color_${COLORS_ARRAY[($START_INDEX + 1) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE" 
        sed -i "/\\\$directory/,/\\\$git_branch/ s/\[\](bg:color_[a-zA-Z0-9_]*/[](bg:color_${COLORS_ARRAY[($START_INDEX + 3) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"

        sed -i "/^\[git_branch\]/,/^\[/ s/bg:color_[a-zA-Z0-9_]*/bg:color_${COLORS_ARRAY[($START_INDEX + 3) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"
        sed -i "/^\[git_status\]/,/^\[/ s/bg:color_[a-zA-Z0-9_]*/bg:color_${COLORS_ARRAY[($START_INDEX + 3) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"
        sed -i "/\\\$git_status/,/\\\$c/ s/\(\[\](bg:color_[a-zA-Z0-9_]* \)fg:color_[a-zA-Z0-9_]*/\1fg:color_${COLORS_ARRAY[($START_INDEX + 3) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"
        sed -i "/\\\$git_status/,/\\\$c/ s/\[\](bg:color_[a-zA-Z0-9_]*/[](bg:color_${COLORS_ARRAY[($START_INDEX + 4) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"

        sed -i "/\\\$python/,/\\\$docker_context/ s/\(\[\](bg:color_[a-zA-Z0-9_]* \)fg:color_[a-zA-Z0-9_]*/\1fg:color_${COLORS_ARRAY[($START_INDEX + 4) % ${#COLORS_ARRAY[@]}]}/" "$TARGET_FILE"
        sed -i "/\\\$python/,/\\\$docker_context/ s/\[\](bg:color_[a-zA-Z0-9_]*/[](bg:color_bg1/" "$TARGET_FILE"
    fi
fi

# -----------------------------------------------------
# 8. APPLICATION: BTOP 
# -----------------------------------------------------
if command -v btop &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/btop.config/btop/themes/${MODE}.theme"
    TARGET_FILE="$CONFIG_DIR/btop/themes/current.theme"
    SETTINGS_FILE="$CONFIG_DIR/btop/btop.conf"

    cp "$TEMPLATE_FILE" "$TARGET_FILE"

    if [[ -f "$BTOP_CONF_FILE" ]]; then
        sed -i "s|^color_theme =.*|color_theme = \"$BTOP_TARGET_FILE\"|" "$BTOP_CONF_FILE"
    fi
fi

# -----------------------------------------------------
# 7. Application: WAYBAR
# -----------------------------------------------------
if command -v waybar &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/waybar/.config/waybar/colors-${MODE}.css"
    TARGET_FILE="$CONFIG_DIR/waybar/colors.css"

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo " Error: Template '$TEMPLATE_FILE' not found!"
        exit 1
    fi
    
    BASE_ACCENT="${ACCENT%_br}"
    
    VAR_NORMAL="${BASE_ACCENT}"      # "red"
    VAR_BRIGHT="${BASE_ACCENT}_br"   # "red_br"
    
    HEX_NORMAL="${!VAR_NORMAL}"      
    HEX_BRIGHT="${!VAR_BRIGHT}"      
   
    if [[ -z "$HEX_NORMAL" ]]; then HEX_NORMAL="$HEX_BRIGHT"; fi

    
    rm -f "$TARGET_FILE"
    cp "$TEMPLATE_FILE" "$TARGET_FILE"
    
    sed -i "s/@define-color accent_br.*/@define-color accent_br $HEX_BRIGHT;/" "$TARGET_FILE"
    sed -i "s/@define-color accent .*/@define-color accent $HEX_NORMAL;/" "$TARGET_FILE"

   
    pkill -SIGUSR2 waybar
fi

# -----------------------------------------------------
# 8. Application: MICRO EDITOR
# -----------------------------------------------------
if command -v micro &> /dev/null; then
    
    TEMPLATE_FILE="$DOTFILES/micro/.config/micro/colorschemes/gruvbox-${MODE}.micro"
    TARGET_FILE="$CONFIG_DIR/micro/colorschemes/custom.micro"
    SETTINGS_FILE="$CONFIG_DIR/micro/settings.json"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        
        cat "$TEMPLATE_FILE" > "$TARGET_FILE"

        if [[ -f "$SETTINGS_FILE" ]]; then
            if ! grep -q '"colorscheme": "custom"' "$SETTINGS_FILE"; then
                 sed 's/"colorscheme": ".*"/"colorscheme": "custom"/' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
            fi
        fi
    fi
fi

# -----------------------------------------------------
# 10. Application: MAKO 
# -----------------------------------------------------
if command -v mako &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/mako/.config/mako/${MODE}" 
    TARGET_FILE="$HOME/.config/mako/config"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        BASE_ACCENT="${ACCENT%_br}"
        if [ "$MODE" == "dark" ]; then VAR_NAME="${BASE_ACCENT}_br"; else VAR_NAME="${BASE_ACCENT}"; fi
        MAKO_BORDER="${!VAR_NAME}"
       
        if [[ -z "$MAKO_BORDER" ]]; then MAKO_BORDER="${!BASE_ACCENT}"; fi
        
        rm -f $TARGET_FILE
        sed "0,/^border-color=/s/^border-color=.*/border-color=$MAKO_BORDER/" "$TEMPLATE_FILE" > "$TARGET_FILE"
    fi
    makoctl reload >/dev/null 2>&1 || true
fi



