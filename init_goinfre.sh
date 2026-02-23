#!/bin/bash
set -euo pipefail

# --- 1. CONFIG ---
GOINFRE="/goinfre/$USER"
MY_APPS="$GOINFRE/apps"
LOCAL_BIN="$HOME/.local/bin"

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

# --- 3. VS CODE ---
if [ ! -f "$MY_APPS/vscode/bin/code" ]; then
    echo "📦 Downloading VS Code..."
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -o "$GOINFRE/vscode.tar.gz"
    mkdir -p "$MY_APPS/vscode"
    tar -xzf "$GOINFRE/vscode.tar.gz" -C "$MY_APPS/vscode" --strip-components=1
    rm "$GOINFRE/vscode.tar.gz"
fi
ln -sf "$MY_APPS/vscode/bin/code" "$LOCAL_BIN/code"

# --- 4. ALACRITTY (Binary instead of Compile) ---
if [ ! -f "$LOCAL_BIN/alacritty" ]; then
    echo "🖥️ Fetching Alacritty Binary..."
    curl -L "https://github.com/raymond-design/alacritty-bin/raw/main/alacritty_linux_x86_64" -o "$LOCAL_BIN/alacritty"
    chmod +x "$LOCAL_BIN/alacritty"
fi

# --- 5. MPV & FFMPEG & YT-DLP ---
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

# --- 6. NPM TOOLS ---
echo "🛠️ Installing Gemini & OpenCode..."
mkdir -p "$MY_APPS/npm-global"
npm config set prefix "$MY_APPS/npm-global"
export PATH="$MY_APPS/npm-global/bin:$PATH"
[ ! -f "$MY_APPS/npm-global/bin/gemini" ] && npm install -g @google/gemini-cli --quiet
[ ! -f "$MY_APPS/npm-global/bin/opencode" ] && npm install -g opencode-ai --quiet
[ ! -f "$MY_APPS/npm-global/bin/codex" ] && npm install -g @openai/codex --quiet

# --- 7. WALLPAPERS (The 'Whole Manga' Scraper) ---
TARGET="$GOINFRE/Wallpapers/manga"
if [ ! -d "$TARGET" ] || [ -z "$(ls -A "$TARGET")" ]; then
    echo "🏮 Scraping the entire Manga folder (Please wait, this is big)..."
    mkdir -p "$TARGET"

    # 1. Get the list of filenames from GitHub API
    # 2. Filter for only image files
    # 3. Download each one
    curl -s "https://api.github.com/repos/dharmx/walls/contents/manga" | \
    grep -oP '"name": "\K[^"]+' | \
    while read -r filename; do
        if [[ "$filename" == *.jpg || "$filename" == *.jpeg || "$filename" == *.png ]]; then
            echo "📥 Downloading: $filename"
            curl -Lf "https://raw.githubusercontent.com/dharmx/walls/main/manga/$filename" \
                 -o "$TARGET/$filename" --silent --show-error
        fi
    done

    # Grab the specific ones from other folders too
    echo "📥 Fetching extras (m-26 and Stalenhag)..."
    curl -Lf "https://raw.githubusercontent.com/dharmx/walls/main/minimalist/m-26.jpg" -o "$GOINFRE/Wallpapers/m-26.jpg" --silent
    echo "✅ Manga folder is fully synced at $TARGET"
fi

# Optional: Grab the Stalenhag collection too
STAL_DIR="$GOINFRE/Wallpapers/stalenhag"
mkdir -p "$STAL_DIR"
curl -s "https://api.github.com/repos/dharmx/walls/contents/stalenhag" | \
grep -oP '"name": "\K[^"]+' | while read -r f; do
    curl -Lf "https://raw.githubusercontent.com/dharmx/walls/main/stalenhag/$f" -o "$STAL_DIR/$f" --silent
done

# --- 8. FINAL SYMLINKS ---
echo "🔗 Finalizing Portals..."
mkdir -p "$GOINFRE/nvim_data" "$GOINFRE/nvim_state"
ln -sfn "$GOINFRE/nvim_data" "$HOME/.local/share/nvim"
ln -sfn "$GOINFRE/nvim_state" "$HOME/.local/state/nvim"
ln -sfn "$GOINFRE/vscode_data" "$HOME/.vscode/extensions"

hash -r
echo "✅ GOINFRE READY. Ready to Rice."
