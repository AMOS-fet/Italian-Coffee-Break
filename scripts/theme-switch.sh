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
    TARGET_FILE="$CONFIG_DIR/btop/themes/current.theme"
    BTOP_CONF_FILE="$CONFIG_DIR/btop/btop.conf"

    if [[ -f "$TEMPLATE_FILE" ]]; then
        mkdir -p "$(dirname "$TARGET_FILE")"
        cp "$TEMPLATE_FILE" "$TARGET_FILE"

        if [[ -f "$BTOP_CONF_FILE" ]]; then
             sed -i "s|^color_theme =.*|color_theme = \"$TARGET_FILE\"|" "$BTOP_CONF_FILE"
        fi
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

echo "@define-color accent_color $NEW_HEX;
@define-color accent_bg_color $NEW_HEX;
@define-color theme_selected_bg_color $NEW_HEX;
@define-color theme_selected_fg_color $TEXT_COLOR;
selection {
    background-color: $NEW_HEX;
    color: $TEXT_COLOR;
}" > "$GTK4_CSS"


cat > "$GTK3_CSS" <<EOF
@define-color accent_color $NEW_HEX;
@define-color accent_bg_color $NEW_HEX;
@define-color theme_selected_bg_color $NEW_HEX;
@define-color theme_selected_fg_color $TEXT_COLOR;

selection,
*:selected,
entry selection,
textview text selection,
label selection,
flowbox flowboxchild:selected {
    background-color: $NEW_HEX;
    color: $TEXT_COLOR;
}

window entry:focus,
window .entry:focus,
window combobox entry:focus,
.background entry:focus,
notebook entry:focus {
    border-color: $NEW_HEX;
    box-shadow: inset 0 0 0 1px $NEW_HEX;
    caret-color: $NEW_HEX;
}

scale trough,
scale.marks trough {
    background-image: none;
    background-color: rgba(60, 60, 60, 0.4); 
    border-radius: 6px;
    min-height: 6px; 
    min-width: 6px; 
    margin: 6px 0;   
}

scale highlight,
scale trough highlight,
scale:focus highlight,
scale.marks highlight,
scale.marks trough highlight,
scale fill,
scale.marks fill {
    background-image: none;
    background-color: $NEW_HEX;
    border-radius: 6px;
    min-height: 6px;
    min-width: 6px;
}

scale slider,
scale.marks slider,
scale:hover slider {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
    border-radius: 100%;
    color: $NEW_HEX;
    min-height: 18px; 
    min-width: 18px;
    margin: -6px;     
    box-shadow: 0 1px 2px rgba(0,0,0,0.3); 
}

progressbar progress,
progressbar.osd progress {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
}

levelbar block.high,
levelbar block.low,
levelbar block.filled {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
}

treeview.view:selected,
column-header .title:selected,
row:selected {
    background-color: $NEW_HEX;
    color: $TEXT_COLOR;
}
check:checked,
radio:checked {
    background-color: $NEW_HEX;
    color: $TEXT_COLOR;
    border-color: $NEW_HEX;
}
switch:checked {
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
}
switch:checked slider {
    background-color: $TEXT_COLOR;
}

button.suggested-action,
button.destructive-action,
button.text-button.suggested-action {
    background-image: none;
    background-color: $NEW_HEX;
    border-color: $NEW_HEX;
    color: $TEXT_COLOR;
}
button.link, link {
    color: $NEW_HEX;
}

notebook > header tab:checked {
    box-shadow: inset 0 -3px $NEW_HEX;
}
EOF

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
# 13. Application: MICRO EDITOR
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
# 14. Application: MAKO 
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



