# PATS EXPORTATION
export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/school-config/bin:$PATH"

# Run init_goinfre ONLY if it hasn't run since we logged in
if [ ! -f "/tmp/goinfre_ready_$USER" ]; then
    if [ -f "$HOME/init_goinfre.sh" ]; then
        bash "$HOME/init_goinfre.sh" > /dev/null
        touch "/tmp/goinfre_ready_$USER" # Create a flag file
    fi
fi

# ---------------------------
# Zinit setup
# ---------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ---------------------------
# Completion system
# ---------------------------
autoload -Uz compinit && compinit

# ---------------------------
# Plugins via zinit
# ---------------------------
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit cdreplay -q

# ---------------------------
# Core utility aliases
# ---------------------------
alias ..='cd ..'
alias l='eza -lh --icons=auto'
alias ls='eza -lha --icons=auto --group-directories-first'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias c='clear'
alias e='exit'
alias vim='nvim'
alias v='nvim'
alias gac='git add . && git commit -m'
alias gs='git status'
alias cls='clear'
alias py='clear; python3'

# ---------------------------
# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

# >>> conda initialize >>>
# This is the ONLY block you need for Conda
__conda_setup="$('/goinfre/aarid/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/goinfre/aarid/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/goinfre/aarid/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/goinfre/aarid/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Start Fastfetch automatically
if command -v fastfetch &> /dev/null; then
    fastfetch
fi


# ----------Random Cyberpunk Theme Picker
if [[ -n "$KITTY_WINDOW_ID" ]]; then
    THEME_FILE="$HOME/school-config/kitty_themes.txt"
    if [ -f "$THEME_FILE" ]; then
        # Pick one random line
        CHOSEN_THEME=$(shuf -n 1 "$THEME_FILE")
        # Apply it instantly to this window
		# If you want each terminal Independent replace 'all' by 'none'
        kitten themes --reload-in=all "$CHOSEN_THEME"
    fi
fi


#----------------------------------------------------------------------------------------
#Open your terminal and type: 
#
#  'xprop -format _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0x7FFFFFFF'
#
#
#Your cursor will turn into a crosshair.
#
#Click on your LibreWolf browser.
#
#If it turns 50% transparent: Success! You just found the holy grail for school machines.
#
#If nothing happens: Your machine is using Wayland, and we need to use a different trick.
#
#OR == 
#-----------------------------------------------------------------------------------------

# Change window opacity by percentage
# Usage: glass 70
function glass() {
    local percent=$1
    if [[ -z "$percent" ]]; then
        echo "Usage: glass [percentage]"
        return 1
    fi
    # Calculate the hex value automatically
    local hex_val=$(printf '0x%x' $((0xffffffff * percent / 100)))
    echo "Click on the window to set opacity to ${percent}%..."
    xprop -format _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY "$hex_val"
}



alias gitkittyoff='git update-index --assume-unchanged .config/kitty/kitty.conf'
alias gitkittyon='git update-index --no-assume-unchanged .config/kitty/kitty.conf'
