# -----------------------------------------------------
# File: .zshrc
# Description: Zsh configuration file
# Author: Amos
# -----------------------------------------------------

# -----------------------------------------------------
# 1. CORE CONFIGURATION
# -----------------------------------------------------

# Completion Engine
autoload -Uz compinit
compinit

# History Settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY

# Auto-Correction
setopt CORRECT
SPROMPT='zsh: Did you mean %F{yellow}%R%f instead of %F{red}%r%f? [nyae] '

# -----------------------------------------------------
# 2. PLUGINS (ARCH LINUX PATHS)
# -----------------------------------------------------

# Autosuggestions
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# History Substring Search
[ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] && \
    source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# FZF Integration
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# -----------------------------------------------------
# 3. THEME & APPEARANCE
# -----------------------------------------------------

# Starship Prompt
eval "$(starship init zsh)"

# Fastfetch (Interactive only)
if [[ -o interactive ]]; then
    fastfetch --config ~/.config/fastfetch/config.jsonc
fi

# Autosuggestions Color (Gruvbox Gray)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#928374'

# Syntax Highlighting Colors (Gruvbox Mapping)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=2'                 # Green
ZSH_HIGHLIGHT_STYLES[alias]='fg=6'                   # Aqua
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=1,bold'      # Red Bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=3'  # Yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=3'  # Yellow
ZSH_HIGHLIGHT_STYLES[path]='none'                    # Default
ZSH_HIGHLIGHT_STYLES[precommand]='fg=5'              # Purple
ZSH_HIGHLIGHT_STYLES[arg0]='fg=2'                    # Green
ZSH_HIGHLIGHT_STYLES[cursor]='none'
ZSH_HIGHLIGHT_STYLES[root]='none'

# Syntax Highlighting Source (Must be last)
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -----------------------------------------------------
# 4. FUNCTIONS & WRAPPERS
# -----------------------------------------------------

# Yazi Wrapper (allows cd on exit)
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# -----------------------------------------------------
# 5. ALIASES
# -----------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --color=auto'
alias c='clear'
alias update='yay -Syu'

# -----------------------------------------------------
# 6. KEYBINDINGS & WIDGETS
# -----------------------------------------------------

# History Search (Up/Down)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- CUSTOM SELECTION LOGIC ---

# Shift + Right (Select Forward)
function shift-select-right {
  [[ "$REGION_ACTIVE" -eq 0 ]] && zle set-mark-command
  zle forward-char
}
zle -N shift-select-right
bindkey '^[[1;2C' shift-select-right

# Shift + Left (Select Backward)
function shift-select-left {
  [[ "$REGION_ACTIVE" -eq 0 ]] && zle set-mark-command
  zle backward-char
}
zle -N shift-select-left
bindkey '^[[1;2D' shift-select-left

# Backspace on Selection
function delete-selection-or-backspace {
  if [[ "$REGION_ACTIVE" -eq 1 ]]; then
    zle kill-region
    REGION_ACTIVE=0
  else
    zle backward-delete-char
  fi
}
zle -N delete-selection-or-backspace
bindkey '^?' delete-selection-or-backspace
bindkey '^H' delete-selection-or-backspace

# --- KITTY INTEGRATION (CUT & SELECT ALL) ---

# Cut (Ctrl+Shift+X) -> Receives ^[[Sx
function zsh-cut-region {
    if [[ "$REGION_ACTIVE" -eq 1 ]]; then
        zle copy-region-as-kill
        print -rn -- "$CUTBUFFER" | wl-copy
        zle kill-region
        REGION_ACTIVE=0
    fi
}
zle -N zsh-cut-region
bindkey '\e[Sx' zsh-cut-region

# Select All (Ctrl+Shift+A) -> Receives ^[[Sa
function zsh-select-all {
    zle end-of-line
    zle set-mark-command
    zle beginning-of-line
}
zle -N zsh-select-all
bindkey '\e[Sa' zsh-select-all
