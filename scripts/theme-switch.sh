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

# --- Wallpaper (AWWW) ---
# Executes the separate script to apply wallpaper and awww settings
setsid $DOTFILES/scripts/apply-neon-$MODE.sh "$ACCENT" >/dev/null 2>&1 &

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
    TARGET_FILE="$DOTFILES/hypr/.config/hypr/colors.conf"

    BASE_ACCENT="${ACCENT%_br}"
    VAR_BRIGHT="${BASE_ACCENT}_br"
    
    HEX_NORMAL="${!BASE_ACCENT}"
    HEX_BRIGHT="${!VAR_BRIGHT}"
    
    if [[ -z "$HEX_NORMAL" ]]; then HEX_NORMAL="$FINAL_ACCENT_HEX"; fi
    if [[ -z "$HEX_BRIGHT" ]]; then HEX_BRIGHT="$HEX_NORMAL"; fi

    HYPR_C1="rgb(${HEX_BRIGHT:1})"
    HYPR_C2="rgb(${HEX_NORMAL:1})"
    
    if [ "$MODE" == "dark" ]; then
        NEW_BORDER="$HYPR_C1 $HYPR_C2 45deg"
        INACTIVE_BORDER="rgb(282828)"
    else
        NEW_BORDER="$HYPR_C2 $HYPR_C1 45deg"
        INACTIVE_BORDER="rgb(e5e5e5)" 
    fi

    echo "\$active_border = $NEW_BORDER" > "$TARGET_FILE"
    echo "\$inactive_border = $INACTIVE_BORDER" >> "$TARGET_FILE"

    hyprctl reload 1> /dev/null     
fi

# -----------------------------------------------------
# 5. Application: ROFI
# -----------------------------------------------------

if command -v rofi &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/rofi/.config/rofi/config-${MODE}.rasi"
    # CORRETTO: Scrive nei dotfiles
    TARGET_FILE="$DOTFILES/rofi/.config/rofi/config.rasi"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        rm -f "$TARGET_FILE"
        cp "$TEMPLATE_FILE" "$TARGET_FILE"
        sed -i "s/border-col:.*;/border-col: $FINAL_ACCENT_HEX;/" "$TARGET_FILE"    
    fi
fi

# -----------------------------------------------------
# 6. Application: KITTY
# -----------------------------------------------------

if command -v kitty &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/kitty/.config/kitty/theme-${MODE}.conf"
    TARGET_FILE="$DOTFILES/kitty/.config/kitty/theme.conf"

    if [[ -f "$TEMPLATE_FILE" ]]; then
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
fi

# -----------------------------------------------------
# 7. Application: STARSHIP 
# -----------------------------------------------------

if command -v starship &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/starship/.config/starship-${MODE}.toml"
    TARGET_FILE="$DOTFILES/starship/.config/starship.toml"

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
        echo " Error: Accent color not supported!"
    else
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
fi

# -----------------------------------------------------
# 8. Application: BTOP 
# -----------------------------------------------------

if command -v btop &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/btop/.config/btop/themes/${MODE}.theme"
    # CORRETTO: Scrive nei dotfiles
    TARGET_FILE="$DOTFILES/btop/.config/btop/themes/current.theme"
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        mkdir -p "$(dirname "$TARGET_FILE")"
        cp "$TEMPLATE_FILE" "$TARGET_FILE"
    fi
fi

# -----------------------------------------------------
# 9. Application: Librewolf
# -----------------------------------------------------

if command -v librewolf &> /dev/null; then
    LIBREWOLF_DIR="$(find "$HOME/.librewolf" -maxdepth 1 -type d \( -name "*.default-default" -o -name "*.default" -o -name "*.default-release" \) | head -n 1)"
    
    if [[ -z "$LIBREWOLF_DIR" ]]; then
        echo " Error: Librewolf profile not found!"
    else
        TEMPLATE_FILE1="$DOTFILES/librewolf/.librewolf/chrome/userChrome-$MODE.css"
        TEMPLATE_FILE2="$DOTFILES/librewolf/.librewolf/chrome/userContent-$MODE.css"  
        TARGET_FILE1="$LIBREWOLF_DIR/chrome/userChrome.css"
        TARGET_FILE2="$LIBREWOLF_DIR/chrome/userContent.css"
        
        if [[ -f "$TEMPLATE_FILE1" ]]; then
            mkdir -p "$(dirname "$TARGET_FILE1")"
            if cp "$TEMPLATE_FILE1" "$TARGET_FILE1"; then
                sed -i "s|^[[:space:]]*--gruvbox-border:.*|  --gruvbox-border: $FINAL_ACCENT_HEX;|" "$TARGET_FILE1"
            fi
        fi

        if [[ -f "$TEMPLATE_FILE2" ]]; then
            mkdir -p "$(dirname "$TARGET_FILE2")"
            cp "$TEMPLATE_FILE2" "$TARGET_FILE2"
        fi
    fi
fi


# -----------------------------------------------------
# 10. SYSTEM: GTK THEME 
# -----------------------------------------------------

if [ "$MODE" == "dark" ]; then
    THEME_NAME="Colloid-Dark"
    ICON_THEME="WhiteSur-dark"       
    COLOR_SCHEME="prefer-dark"
    GTK_PREFER_DARK="1"
    GS_PREFER_DARK="true"
else
    THEME_NAME="Colloid-Light"
    ICON_THEME="WhiteSur-light"       
    COLOR_SCHEME="default"
    GTK_PREFER_DARK="0"
    GS_PREFER_DARK="false"
fi

CURSOR_THEME="${TARGET_CURSOR:-phinger-cursors-light}"

if [[ ! -d "/usr/share/icons/$ICON_THEME" ]] && \
   [[ ! -d "$HOME/.local/share/icons/$ICON_THEME" ]] && \
   [[ ! -d "$HOME/.icons/$ICON_THEME" ]]; then
    ICON_THEME="Adwaita"
fi

if [[ ! -d "/usr/share/icons/$CURSOR_THEME" ]] && \
   [[ ! -d "$HOME/.local/share/icons/$CURSOR_THEME" ]] && \
   [[ ! -d "$HOME/.icons/$CURSOR_THEME" ]]; then
    CURSOR_THEME="Adwaita"
fi


GTK3_FILE="$CONFIG_DIR/gtk-3.0/settings.ini"
GTK2_FILE="$HOME/.gtkrc-2.0"

cat > "$GTK3_FILE" <<EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=SF Pro 11
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-application-prefer-dark-theme=$GTK_PREFER_DARK
EOF

cat > "$GTK2_FILE" <<EOF
gtk-theme-name="$THEME_NAME"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="SF Pro 11"
gtk-cursor-theme-name="$CURSOR_THEME"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
EOF

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME"
    gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme "$GS_PREFER_DARK" 2>/dev/null

    if gsettings list-schemas | grep -q "org.cinnamon.desktop.interface"; then
        gsettings set org.cinnamon.desktop.interface gtk-theme "$THEME_NAME"
        gsettings set org.cinnamon.desktop.interface gtk-application-prefer-dark-theme "$GS_PREFER_DARK" 2>/dev/null
        gsettings set org.cinnamon.desktop.interface icon-theme "$ICON_THEME"
        gsettings set org.cinnamon.desktop.interface cursor-theme "$CURSOR_THEME"
    fi
fi

export GTK_THEME="$THEME_NAME"
if command -v hyprctl &> /dev/null; then
    hyprctl setenv GTK_THEME "$THEME_NAME" 2>/dev/null
fi

if pgrep -x "xsettingsd" > /dev/null; then killall -HUP xsettingsd; fi
if pgrep -x "nemo" > /dev/null; then nemo -q >/dev/null 2>&1; fi


NEW_HEX="$FINAL_ACCENT_HEX"
TEXT_COLOR="#F9EDD2" 
if [ "$MODE" == "light" ]; then TEXT_COLOR="#282828"; fi

GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
mkdir -p "$(dirname "$GTK3_CSS")"
mkdir -p "$(dirname "$GTK4_CSS")"

# Creiamo un blocco CSS unificato e ad alta specificità
COMMON_CSS="@define-color accent_color $NEW_HEX;
@define-color accent_bg_color $NEW_HEX;
@define-color theme_selected_bg_color $NEW_HEX;
@define-color theme_selected_fg_color $TEXT_COLOR;

/* SELEZIONE */
window selection,
window *:selected,
window entry selection,
window textview text selection,
window label selection,
window flowbox flowboxchild:selected {
    background-color: $NEW_HEX;
    color: $TEXT_COLOR;
}

/* INPUT E CAMPI DI TESTO */
window entry:focus,
window .entry:focus,
window combobox entry:focus,
window notebook entry:focus {
    border-color: $NEW_HEX;
    box-shadow: inset 0 0 0 1px $NEW_HEX;
    caret-color: $NEW_HEX;
}

/* SLIDER E PROGRESS BAR */
window scale highlight,
window scale trough highlight,
window scale:focus highlight,
window scale fill,
window scale.marks fill {
    background-image: none;
    background-color: $NEW_HEX;
}

window scale slider,
window scale.marks slider,
window scale:hover slider {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
    color: $NEW_HEX;
}

window progressbar progress,
window progressbar.osd progress {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
}

/* PULSANTI (Fix per i colori residui) */
window button.suggested-action,
window button.destructive-action,
window headerbar button.suggested-action,
dialog button.suggested-action,
popover button.suggested-action,
window button.text-button.suggested-action {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
    color: $TEXT_COLOR;
}

window button.link, 
window link {
    color: $NEW_HEX;
}

/* SWITCH, CHECKBOX E RADIO BUTTON */
window check:checked,
window radio:checked {
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
    color: $TEXT_COLOR;
}

window switch:checked {
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
}

window switch:checked slider {
    background-color: $TEXT_COLOR;
}

window notebook > header tab:checked {
    box-shadow: inset 0 -3px $NEW_HEX;
}"

# Applichiamo lo stesso blocco sia a GTK3 che a GTK4
echo "$COMMON_CSS" > "$GTK3_CSS"
echo "$COMMON_CSS" > "$GTK4_CSS"

if command -v gsettings &> /dev/null; then
   # Force theme refresh
   gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
   sleep 0.1
   gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
fi

# -----------------------------------------------------
# 11. System: HYPRLAND CURSOR & ICONS
# -----------------------------------------------------

HYPR_CONF="$CONFIG_DIR/hypr/hyprland.conf"
CURSOR_SIZE=24

if [[ -f "$HYPR_CONF" ]]; then
    if [[ -d "/usr/share/icons/$CURSOR_THEME" ]] || \
       [[ -d "$HOME/.local/share/icons/$CURSOR_THEME" ]] || \
       [[ -d "$HOME/.icons/$CURSOR_THEME" ]]; then
       
       if grep -q "env = XCURSOR_THEME," "$HYPR_CONF"; then
           sed -i "s|^env = XCURSOR_THEME,.*|env = XCURSOR_THEME,$CURSOR_THEME|" "$HYPR_CONF"
       fi
       
       if grep -q "env = XCURSOR_SIZE," "$HYPR_CONF"; then
           sed -i "s|^env = XCURSOR_SIZE,.*|env = XCURSOR_SIZE,$CURSOR_SIZE|" "$HYPR_CONF"
       fi
 
       if command -v hyprctl &> /dev/null; then
           hyprctl setcursor "$CURSOR_THEME" $CURSOR_SIZE 2>/dev/null
           hyprctl setenv XCURSOR_THEME "$CURSOR_THEME" 2>/dev/null
           hyprctl setenv XCURSOR_SIZE "$CURSOR_SIZE" 2>/dev/null
       fi   
    fi

    if [[ -d "/usr/share/icons/$ICON_THEME" ]] || \
       [[ -d "$HOME/.local/share/icons/$ICON_THEME" ]] || \
       [[ -d "$HOME/.icons/$ICON_THEME" ]]; then
       
       if grep -q "env = GTK_ICON_THEME," "$HYPR_CONF"; then
           sed -i "s|^env = GTK_ICON_THEME,.*|env = GTK_ICON_THEME,$ICON_THEME|" "$HYPR_CONF"
       fi
       
       if command -v hyprctl &> /dev/null; then
           hyprctl setenv GTK_ICON_THEME "$ICON_THEME" 2>/dev/null
       fi
    fi
fi

# -----------------------------------------------------
# 12. Application: WAYBAR
# -----------------------------------------------------

if command -v waybar &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/waybar/.config/waybar/colors-${MODE}.css"
    # CORRETTO: Scrive nei dotfiles
    TARGET_FILE="$DOTFILES/waybar/.config/waybar/colors.css"

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

fi

# -----------------------------------------------------
# 13. Application: bulletty 
# -----------------------------------------------------

if command -v bulletty &> /dev/null; then
    TEMPLATE_FILE="$DOTFILES/bulletty/.config/bulletty/config-${MODE}.toml"
    # CORRETTO: Scrive nei dotfiles
    TARGET_FILE="$DOTFILES/bulletty/.config/bulletty/config.toml"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        mkdir -p "$(dirname "$TARGET_FILE")"
        cp "$TEMPLATE_FILE" "$TARGET_FILE"
    fi
fi

# -----------------------------------------------------
# 14. Application: NVIM
# -----------------------------------------------------

# if command -v nvim &> /dev/null; then
#    TEMPLATE_FILE="$DOTFILES/nvim/.config/nvim/lua/coffee_break.lua"
#    TARGET_FILE="$DOTFILES/nvim/.config/nvim/lua/coffee_break.lua"
#
#    TEMPLATE_BG="$DOTFILES/nvim/.config/nvim/lua/config/bg_mode.lua"
#    TARGET_BG="$DOTFILES/nvim/.config/nvim/lua/config/bg_mode.lua"
#    
#    if [[ -f "$TEMPLATE_FILE" ]]; then
#        rm -f "$TARGET_FILE"
#        cp "$TEMPLATE_FILE" "$TARGET_FILE"    
#    fi
#
#    if [[ -f "$TEMPLATE_BG" ]]; then
#        rm -f "$TARGET_BG"
#        cp "$TEMPLATE_BG" "$TARGET_BG"    
#        sed -i "s/vim.o.background:.*;/vim.o.background: $MODE;/" "$TARGET_BG"
#    fi
# fi

# -----------------------------------------------------
# 15. Application: MAKO 
# -----------------------------------------------------

if command -v mako &> /dev/null; then
    
    HEX_MAKO="$FINAL_ACCENT_HEX"
    if [[ ! "$HEX_MAKO" == \#* ]]; then
        HEX_MAKO="#$HEX_MAKO"
    fi

    TEMPLATE_FILE="$DOTFILES/mako/.config/mako/${MODE}" 
    TARGET_FILE="$DOTFILES/mako/.config/mako/config"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        rm -f "$TARGET_FILE"
        cp "$TEMPLATE_FILE" "$TARGET_FILE"

        sed -i "s|ACCENT_COLOR|$HEX_MAKO|" "$TARGET_FILE"
    fi
    
    killall mako 2>/dev/null
    sleep 0.1
    mako >/dev/null 2>&1 &
    disown
fi


# -----------------------------------------------------
# 16. Application: MICRO EDITOR
# -----------------------------------------------------

if command -v micro &> /dev/null; then
    
    TEMPLATE_FILE="$DOTFILES/micro/.config/micro/colorschemes/gruvbox-${MODE}.micro"
    # CORRETTO: Scrive nei dotfiles
    TARGET_FILE="$DOTFILES/micro/.config/micro/colorschemes/custom.micro"
    # CORRETTO: Scrive nei dotfiles
    SETTINGS_FILE="$DOTFILES/micro/.config/micro/settings.json"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        
        cat "$TEMPLATE_FILE" > "$TARGET_FILE"

        if [[ -f "$SETTINGS_FILE" ]]; then
            if ! grep -q '"colorscheme": "custom"' "$SETTINGS_FILE"; then
                 sed 's/"colorscheme": ".*"/"colorscheme": "custom"/' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
            fi
        fi
    fi
fi

pkill -SIGUSR2 waybar
