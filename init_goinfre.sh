#!/bin/bash
set -euo pipefail

# --- 1. CONFIG ---
GOINFRE="/goinfre/$USER"
MY_APPS="$GOINFRE/apps"
LOCAL_BIN="$HOME/.local/bin"

export GOINFRE="/goinfre/$USER"
export CARGO_HOME="$GOINFRE/cargo_home"
export PATH="$CARGO_HOME/bin:$PATH"

mkdir -p "$GOINFRE" "$MY_APPS" "$LOCAL_BIN" "$GOINFRE/vscode_data"

echo "🚀 Starting Ultimate Goinfre Setup..."

# --- 2. FAST CONDA & NODE ---
if [ ! -d "$GOINFRE/miniconda3" ]; then
    echo "🐍 Installing Miniforge (Fast Conda)..."
    curl -L "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" -o /tmp/miniforge.sh
    bash /tmp/miniforge.sh -b -u -p "$GOINFRE/miniconda3"
    rm /tmp/miniforge.sh
fi

source "$GOINFRE/miniconda3/etc/profile.d/conda.sh"
conda activate base

if ! command -v node &> /dev/null || [[ $(node -v) != v20* ]]; then
    echo "📦 Updating Node.js to v20..."
    conda install -y -c conda-forge nodejs=20 python=3.11 --quiet
fi

# --- 3. NEOVIM (Robust Download) ---
# If file doesn't exist OR is smaller than 1MB (fake error page), download it.
if [ ! -s "$MY_APPS/nvim" ] || [ $(stat -c%s "$MY_APPS/nvim") -lt 1000000 ]; then
    echo "🌙 Downloading real Neovim AppImage..."
    rm -f "$MY_APPS/nvim"
    curl -L "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage" -o "$MY_APPS/nvim"
    chmod +x "$MY_APPS/nvim"
fi
ln -sfn "$MY_APPS/nvim" "$LOCAL_BIN/nvim"

# --- 4. VS CODE ---
if [ ! -f "$MY_APPS/vscode/bin/code" ]; then
    echo "📦 Downloading VS Code..."
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -o "$GOINFRE/vscode.tar.gz"
    mkdir -p "$MY_APPS/vscode"
    tar -xzf "$GOINFRE/vscode.tar.gz" -C "$MY_APPS/vscode" --strip-components=1
    rm "$GOINFRE/vscode.tar.gz"
fi
ln -sf "$MY_APPS/vscode/bin/code" "$LOCAL_BIN/code"

# --- 5. ALACRITTY (Source Build for Firewall Bypass) ---
if ! command -v alacritty &> /dev/null; then
    echo "🏗️ Building Alacritty from source..."
    conda install -y -c conda-forge rust --quiet
    
    export CARGO_HOME="$GOINFRE/cargo_home"
    mkdir -p "$CARGO_HOME"
    
    cargo install alacritty
    ln -sfn "$CARGO_HOME/bin/alacritty" "$LOCAL_BIN/alacritty"
fi

# --- 6. MPV & FFMPEG ---
if [ ! -f "$MY_APPS/mpv" ]; then
    echo "🎬 Installing MPV..."
    LATEST_MPV=$(curl -s https://api.github.com/repos/pkgforge-dev/mpv-AppImage/releases/latest | grep "browser_download_url.*x86_64.AppImage" | head -n 1 | cut -d '"' -f 4)
    curl -L "$LATEST_MPV" -o "$MY_APPS/mpv"
    chmod +x "$MY_APPS/mpv"
fi
ln -sfn "$MY_APPS/mpv" "$LOCAL_BIN/mpv"

if [ ! -f "$LOCAL_BIN/ffmpeg" ]; then
    echo "🎞 Installing FFmpeg..."
    curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o "$MY_APPS/ffmpeg.tar.xz"
    mkdir -p "$MY_APPS/ff_tmp"
    tar -xJf "$MY_APPS/ffmpeg.tar.xz" -C "$MY_APPS/ff_tmp" --strip-components=1
    cp "$MY_APPS/ff_tmp/ffmpeg" "$MY_APPS/ff_tmp/ffprobe" "$LOCAL_BIN/"
    chmod +x "$LOCAL_BIN/ffmpeg" "$LOCAL_BIN/ffprobe"
    rm -rf "$MY_APPS/ff_tmp" "$MY_APPS/ffmpeg.tar.xz"
fi

# --- 7. NPM TOOLS ---
echo "🛠️ Installing Gemini & OpenCode..."
mkdir -p "$MY_APPS/npm-global"
npm config set prefix "$MY_APPS/npm-global"
export PATH="$MY_APPS/npm-global/bin:$PATH"
[ ! -f "$MY_APPS/npm-global/bin/gemini" ] && npm install -g @google/gemini-cli --quiet
[ ! -f "$MY_APPS/npm-global/bin/opencode" ] && npm install -g opencode-ai --quiet

# --- 8. FINAL SYMLINKS (The Quota Savers) ---
echo "🔗 Finalizing Portals..."

# Neovim: Link Share (plugins), State (history), and Cache (treesitter/swap)
mkdir -p "$GOINFRE/nvim_share" "$GOINFRE/nvim_state" "$GOINFRE/nvim_cache"
rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
ln -sfn "$GOINFRE/nvim_share" "$HOME/.local/share/nvim"
ln -sfn "$GOINFRE/nvim_state" "$HOME/.local/state/nvim"
ln -sfn "$GOINFRE/nvim_cache" "$HOME/.cache/nvim"

# VS Code Extensions
# Linking the extensions to goinfre also
#rm -rf "$HOME/.vscode/extensions"
#ln -sfn "$GOINFRE/vscode_data" "$HOME/.vscode/extensions"

hash -r
echo "✅ GOINFRE READY. Neovim and VSCode linked to Goinfre."
