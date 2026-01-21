# PATS EXPORTATION
export PATH="$HOME/.local/bin:$PATH"

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
