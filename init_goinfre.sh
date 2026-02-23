#!/bin/bash

# --- 1. CONFIGURATION ---
GOINFRE="/goinfre/$USER"
MY_APPS="$GOINFRE/apps"
LOCAL_BIN="$HOME/.local/bin"

# Create skeleton
mkdir -p "$GOINFRE" "$MY_APPS" "$LOCAL_BIN" "$GOINFRE/vscode_data" "$GOINFRE/conda" "$GOINFRE/nvim_data" "$GOINFRE/nvim_state"

echo "🚀 Running Ultimate Goinfre Setup..."

# --- 2. VS CODE ---
if [ ! -f "$MY_APPS/vscode/bin/code" ]; then
    echo "📦 Installing VS Code..."
    mkdir -p "$MY_APPS/vscode"
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" --output "$GOINFRE/vscode.tar.gz"
    tar -xzf "$GOINFRE/vscode.tar.gz" -C "$MY_APPS/vscode" --strip-components=1
    rm "$GOINFRE/vscode.tar.gz"
fi
ln -sf "$MY_APPS/vscode/bin/code" "$LOCAL_BIN/code"

# --- 3. CONDA ---
if [ ! -d "$GOINFRE/miniconda3" ]; then
    echo "🐍 Installing Conda..."
    curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -u -p "$GOINFRE/miniconda3"
    rm /tmp/miniconda.sh
fi
# Ensure Conda is in the current session PATH immediately
export PATH="$GOINFRE/miniconda3/bin:$PATH"
ln -sfn "$GOINFRE/miniconda3" "$HOME/miniconda3"

# --- 4. DISCORD (WebCord) ---
if [ ! -f "$MY_APPS/discord.AppImage" ] || [ $(stat -c%s "$MY_APPS/discord.AppImage") -lt 1000 ]; then
    echo "💬 Installing Discord (WebCord)..."
    rm -f "$MY_APPS/discord.AppImage"
    curl -Lf "https://github.com/SpacingBat3/WebCord/releases/download/v4.12.1/WebCord-4.12.1-x64.AppImage" -o "$MY_APPS/discord.AppImage"
    chmod +x "$MY_APPS/discord.AppImage"
fi

# FIXED: Added the closing quote below
echo -e "#!/bin/bash\nnohup $MY_APPS/discord.AppImage --no-sandbox > /dev/null 2>&1 &" > "$LOCAL_BIN/discord"
chmod +x "$LOCAL_BIN/discord"

# --- 5. NODE & NPM (Modern v20) ---
# We force Node 20 because Gemini-CLI and OpenCode require modern ESM support
if ! command -v node &> /dev/null || [[ $(node -v) == v12* ]]; then
    echo "📦 Node.js missing or too old. Installing v20 via Conda..."
	conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
	conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
    conda install -c conda-forge nodejs=20 python=3.11 -y
fi

# Fix node-gyp Python conflict
if command -v npm &> /dev/null; then
    npm config set python "$GOINFRE/miniconda3/bin/python"
    mkdir -p "$MY_APPS/npm-global"
    npm config set prefix "$MY_APPS/npm-global"
    export PATH="$MY_APPS/npm-global/bin:$PATH"
fi

# --- 6. CLI TOOLS ---
if command -v npm &> /dev/null; then
    echo "🛠️ Checking global CLI tools..."
    
    # Gemini CLI
    if [ ! -f "$MY_APPS/npm-global/bin/gemini" ]; then
        echo "♊ Installing Gemini CLI..."
        npm install -g @google/gemini-cli
    fi

    # OpenCode AI
    if [ ! -f "$MY_APPS/npm-global/bin/opencode" ]; then
        echo "💻 Installing OpenCode AI..."
        npm install -g opencode-ai
    fi

    if [ ! -f "$MY_APPS/npm-global/bin/codex" ]; then
        echo "💻 Installing Codex AI..."
		npm i -g @openai/codex
    fi
else
    echo "⚠️ npm not found. Skipping CLI tools."
fi

# --- 7. RUST & ALACRITTY ---
export RUSTUP_HOME="$GOINFRE/rustup"
export CARGO_HOME="$GOINFRE/cargo"

if [ ! -d "$CARGO_HOME/bin" ]; then
    echo "🦀 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --profile minimal -y
fi
export PATH="$CARGO_HOME/bin:$PATH"

if [ ! -f "$LOCAL_BIN/alacritty" ]; then
    echo "🖥️ Building Alacritty..."
    git clone https://github.com/alacritty/alacritty.git "$GOINFRE/alacritty_src"
    cd "$GOINFRE/alacritty_src"
    cargo build --release
    cp target/release/alacritty "$LOCAL_BIN/alacritty"
    cd ~ && rm -rf "$GOINFRE/alacritty_src"
fi

# --- 8. PORTALS & FINISH ---
echo "🔗 Opening Portals..."
ln -sfn "$GOINFRE/nvim_data" "$HOME/.local/share/nvim"
ln -sfn "$GOINFRE/nvim_state" "$HOME/.local/state/nvim"
ln -sfn "$GOINFRE/vscode_data" "$HOME/.vscode/extensions"



# anime cli
pip install ani-cli-arabic
# mpv dependencie for ani-cli-arabic ##############################################
# 1. Clean up old failed attempts
rm -f /goinfre/$USER/apps/mpv

# 2. Automatically find and download the latest x86_64 AppImage from pkgforge-dev
# (This repo is more active and consistent than the others)
LATEST_URL=$(curl -s https://api.github.com/repos/pkgforge-dev/mpv-AppImage/releases/latest | grep "browser_download_url.*x86_64.AppImage" | head -n 1 | cut -d '"' -f 4)

echo "Downloading from: $LATEST_URL"
curl -Lf "$LATEST_URL" -o /goinfre/$USER/apps/mpv

# 3. Set permissions and link
chmod +x /goinfre/$USER/apps/mpv
mkdir -p ~/.local/bin
ln -sfn /goinfre/$USER/apps/mpv ~/.local/bin/mpv

# ffmpeg (The video processor - necessary for ani-skip)
# Using the specific latest release build link
curl -Lf https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /goinfre/$USER/apps/ffmpeg.tar.xz
mkdir -p /goinfre/$USER/apps/ff_tmp
tar -xJf /goinfre/$USER/apps/ffmpeg.tar.xz -C /goinfre/$USER/apps/ff_tmp --strip-components=1
cp /goinfre/$USER/apps/ff_tmp/ffmpeg /goinfre/$USER/apps/ff_tmp/ffprobe ~/.local/bin/
chmod +x ~/.local/bin/ffmpeg ~/.local/bin/ffprobe
rm -rf /goinfre/$USER/apps/ff_tmp /goinfre/$USER/apps/ffmpeg.tar.xz
############################################################

hash -r
echo "✅ GOINFRE READY. Ready to Rice."
