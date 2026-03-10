# PATS EXPORTATION
# Goinfre Rust Paths

export PATH="$HOME/school-config/bin:$PATH"
export PATH="/goinfre/$USER/apps/npm-global/bin:$PATH"

export RUSTUP_HOME="/goinfre/$USER/rustup"
export CARGO_HOME="/goinfre/$USER/cargo"
export PATH="$CARGO_HOME/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi




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
alias py='clear; echo "----------------------------------------------------------------------------------"; python3'
# Faster Gemini Chat
alias gc="gemini -i 'Hello!'"
alias ai='codex'



alias cc='gcc'
alias aiopen='opencode'
# ---------------------------
# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
#eval "$(starship init zsh)"

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
alias gitkittyoff='git update-index --assume-unchanged .config/kitty/kitty.conf'
alias gitkittyon='git update-index --no-assume-unchanged .config/kitty/kitty.conf'

# One-command sync to GitHub
function sync() {
    git add .
    # This commits with the current date and time
    git commit -m "Cyberpunk school Update: $(date +'%Y-%m-%d %H:%M')"
    git push origin main
    echo "🛸 System synced to the cloud."
}

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

# Make the browser transparent each time u open terminal or touch ur prompt.
precmd() {
  # Only run if we are on X11 (or XWayland)
  if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
    (
      local ids=$(xwininfo -root -tree | grep -i "Firefox" | grep -oE "0x[0-9a-f]{7,8}")
      for id in ${=ids}; do
        # Use your favorite hex here
        xprop -id "$id" -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xDFFFFFFF 2>/dev/null
      done
    ) &!
  fi
}

# Set lock Wallpaper.
xrdb -merge ~/school-config/.Xresources

alias clr='clear'

alias cclean='bash ~/LinuxCleaner_42.sh'
alias anime='ani-cli-arabic'


source ~/powerlevel10k/powerlevel10k.zsh-theme >> /dev/null

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias scr100='xrandr --output DP-2 --brightness 1'
alias scr200='xrandr --output DP-2 --brightness 2'
alias scr150='xrandr --output DP-2 --brightness 1.5'

alias showlib='ldd'


# 1. Define the list as an ARRAY
MY_WALLPAPER_PATHS=(
    "/goinfre/$USER/Wallpapers"
    "/home/$USER/Pictures/Wallpapers"
)

# 2. Use "${MY_WALLPAPER_PATHS[@]}" to expand them correctly
#IMG=$(find "${MY_WALLPAPER_PATHS[@]}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1)

# 3. Apply the wallpaper
#gsettings set org.gnome.desktop.background picture-uri "file://$IMG"
#gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG"

alias wall='PATHS=("/goinfre/$USER/Wallpapers" "~/Pictures/Wallpapers"); IMG=$(find "${PATHS[@]}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | shuf -n 1) && gsettings set org.gnome.desktop.background picture-uri "file://$IMG" && gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG" && echo "🖼️  New look: $(basename $IMG)"'

# change kitty each time open new session
sh ~/school-config/change_kitty_themes.sh

alias maxthreads=cat /proc/sys/kernel/threads-max
