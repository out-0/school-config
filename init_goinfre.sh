#!/bin/bash
set -euo pipefail

# --- 0. MAINTENANCE (Quota Recovery) ---
echo "🧹 Cleaning home directory ghosts..."
# Nuke old editor configs, unused runtimes, and temp files
rm -rf ~/.emacs.d ~/.SpaceVim.d ~/.bluefish ~/.ssr ~/.gphoto ~/.visualizers ~/.it.swp ~/undefined.bak ~/.dotnet
# Clear massive caches (These rebuild automatically in Goinfre)
rm -rf ~/.npm ~/.cache/pip ~/.cache/fontconfig ~/.cache/motd.legal-displayed
# Targeted Browser Cleanup (Clears Firefox cache to save ~500MB)
find ~/.cache/mozilla/firefox -name "cache2" -type d -exec rm -rf {} + 2>/dev/null || true

# --- 1. CONFIG & PATHS ---
GOINFRE="/goinfre/$USER"
MY_APPS="$GOINFRE/apps"
LOCAL_BIN="$HOME/.local/bin"

export CARGO_HOME="$GOINFRE/cargo_home"
export PATH="$LOCAL_BIN:$CARGO_HOME/bin:$PATH"

mkdir -p "$GOINFRE" "$MY_APPS" "$LOCAL_BIN" "$GOINFRE/vscode-exts" "$GOINFRE/vscode-user-data"

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

# --- 3. NEOVIM (AppImage) ---
if [ ! -s "$MY_APPS/nvim" ] || [ $(stat -c%s "$MY_APPS/nvim") -lt 1000000 ]; then
    echo "🌙 Downloading Neovim AppImage..."
    curl -L "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage" -o "$MY_APPS/nvim"
    chmod +x "$MY_APPS/nvim"
fi
ln -sfn "$MY_APPS/nvim" "$LOCAL_BIN/nvim"

# --- 4. ALACRITTY ---
if ! command -v alacritty &> /dev/null; then
    echo "🏗️ Building Alacritty from source..."
    conda install -y -c conda-forge rust --quiet
    cargo install alacritty
    ln -sfn "$CARGO_HOME/bin/alacritty" "$LOCAL_BIN/alacritty"
fi

# --- 5. FFmpeg & MPV (The Anime Fix) ---
if [ ! -f "$MY_APPS/ffmpeg" ]; then
    echo "🎞 Installing FFmpeg..."
    curl -L "https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz" -o "$MY_APPS/ffmpeg.tar.xz"
    mkdir -p "$MY_APPS/ff_tmp"
    tar -xJf "$MY_APPS/ffmpeg.tar.xz" -C "$MY_APPS/ff_tmp" --strip-components=1
    mv "$MY_APPS/ff_tmp/ffmpeg" "$MY_APPS/ffmpeg"
    mv "$MY_APPS/ff_tmp/ffprobe" "$MY_APPS/ffprobe"
    chmod +x "$MY_APPS/ffmpeg" "$MY_APPS/ffprobe"
    rm -rf "$MY_APPS/ff_tmp" "$MY_APPS/ffmpeg.tar.xz"
fi
ln -sfn "$MY_APPS/ffmpeg" "$LOCAL_BIN/ffmpeg"

if ! command -v mpv &> /dev/null; then
    echo "🎬 Installing MPV via Conda..."
    conda install -y -c conda-forge mpv yt-dlp --quiet
fi
ln -sfn "$(which mpv)" "$LOCAL_BIN/mpv"

# --- 6. VS CODE (Official AppImage & Goinfre Linking) ---
VSCODE_APPIMAGE="$MY_APPS/vscode.AppImage"
if [ ! -f "$VSCODE_APPIMAGE" ]; then
    echo "💙 Downloading Official VS Code AppImage..."
    curl -L "https://github.com/valicm/VSCode-AppImage/releases/download/1.112.0/VSCode-x86_64.AppImage" -o "$VSCODE_APPIMAGE"
    chmod +x "$VSCODE_APPIMAGE"
fi
ln -sfn "$VSCODE_APPIMAGE" "$LOCAL_BIN/code"

# --- 7. QUOTA SAVER LINKS (The Brain & Muscles) ---
echo "🔗 Linking VS Code Folders to Goinfre..."

# Extensions: Move from Home to Goinfre
[ -d "$HOME/.vscode" ] && [ ! -L "$HOME/.vscode" ] && rm -rf "$HOME/.vscode"
mkdir -p "$HOME/.vscode"
ln -sfn "$GOINFRE/vscode-exts" "$HOME/.vscode/extensions"

# User Data (Settings/Cache): Move from .config to Goinfre
mkdir -p "$HOME/.config"
[ -d "$HOME/.config/Code" ] && [ ! -L "$HOME/.config/Code" ] && rm -rf "$HOME/.config/Code"
ln -sfn "$GOINFRE/vscode-user-data" "$HOME/.config/Code"

# Neovim Cache/State: Move to Goinfre
mkdir -p "$GOINFRE/nvim_share" "$GOINFRE/nvim_state" "$GOINFRE/nvim_cache"
rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
ln -sfn "$GOINFRE/nvim_share" "$HOME/.local/share/nvim"
ln -sfn "$GOINFRE/nvim_state" "$HOME/.local/state/nvim"
ln -sfn "$GOINFRE/nvim_cache" "$HOME/.cache/nvim"

# --- 8. AUTO-EXTENSION INSTALLER (The "Official Name" Fix) ---
EXTENSIONS=(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "christian-kohler.path-intellisense"
    "pkief.material-icon-theme"
    "njpwerner.autodocstring"
    "vscodevim.vim"
	"eamodio.gitlens"
	"KevinRose.vsc-python-indent"
	"tushortz.python-extended-snippets"
	"xirider.livecode"
	"GitHub.github-vscode-theme"
	"BeardedBear.beardedtheme"
	"jdinhlife.gruvbox"
	"DaltonMenezes.aura-theme"
	# "openai.chatgpt"
	"GitHub.copilot-chat"
	"JoseMurilloc.aura-spirit-dracula"
	"esbenp.prettier-vscode"
	"aaron-bond.better-comments"
)

echo "🧩 Syncing VS Code Extensions (Silent Mode)..."
EXT_DIR="$GOINFRE/vscode-exts"
mkdir -p "$EXT_DIR"

for ext in "${EXTENSIONS[@]}"; do
    # 1. Check if ANY folder starting with the extension name exists
    if ! ls "$EXT_DIR" 2>/dev/null | grep -iq "^${ext}"; then
        echo "📥 Downloading $ext..."

        PUB=$(echo "$ext" | cut -d. -f1)
        NAME=$(echo "$ext" | cut -d. -f2)

        VSIX_URL="https://${PUB}.gallery.vsassets.io/_apis/public/gallery/publisher/${PUB}/extension/${NAME}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
        VSIX_FILE="/tmp/${ext}.vsix"
        TMP_EXTRACT="/tmp/${ext}_tmp"

        curl -L "$VSIX_URL" -o "$VSIX_FILE" -s -A "Mozilla/5.0"

        mkdir -p "$TMP_EXTRACT"
        unzip -q "$VSIX_FILE" -d "$TMP_EXTRACT" 2>/dev/null || true

        if [ -d "$TMP_EXTRACT/extension" ]; then
            # 2. GET REAL VERSION: This is the magic part
            # It looks into the package.json to find the version (e.g., 1.2.3)
            VERSION=$(grep -oP '"version":\s*"\K[^"]+' "$TMP_EXTRACT/extension/package.json" || echo "manual")
            REAL_NAME="${ext}-${VERSION}"

            # 3. MOVE TO GOINFRE with the official naming convention
            mv "$TMP_EXTRACT/extension" "$EXT_DIR/$REAL_NAME"
            echo "✅ $ext ($VERSION) installed."
        else
            echo "❌ Failed to extract $ext."
        fi

        rm -rf "$VSIX_FILE" "$TMP_EXTRACT"
    else
        echo "✅ $ext is already present."
    fi
done

echo "✨ Extensions check complete."

# Sync settings from your dotfiles repository
if [ -d "$HOME/school-config/vscode" ]; then
    echo "⚙️ Syncing Settings & Keymaps..."
    mkdir -p "$GOINFRE/vscode-user-data/User"
    ln -sfn "$HOME/school-config/vscode/settings.json" "$GOINFRE/vscode-user-data/User/settings.json"
    ln -sfn "$HOME/school-config/vscode/keybindings.json" "$GOINFRE/vscode-user-data/User/keybindings.json"
fi

# --- 9. FINALIZING ---
hash -r
echo "✅ SETUP COMPLETE."
echo "📊 Current Quota Usage:"
quota -s | grep -A 1 "Filesystem"
