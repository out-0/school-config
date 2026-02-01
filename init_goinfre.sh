#!/bin/bash

# --- 1. CONFIGURATION ---
GOINFRE="/goinfre/$USER"
MY_APPS="$GOINFRE/apps"
LOCAL_BIN="$HOME/.local/bin"

# Create skeleton
mkdir -p "$GOINFRE" "$MY_APPS" "$LOCAL_BIN" "$GOINFRE/vscode_data" "$GOINFRE/conda" "$GOINFRE/nvim_data" "$GOINFRE/nvim_state"

echo "🚀 Running Ultimate Goinfre Setup..."

# --- 2. VS CODE (Standalone in Goinfre) ---
if [ ! -f "$MY_APPS/vscode/bin/code" ]; then
    echo "📦 Installing VS Code..."
    mkdir -p "$MY_APPS/vscode"
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" --output "$GOINFRE/vscode.tar.gz"
    tar -xzf "$GOINFRE/vscode.tar.gz" -C "$MY_APPS/vscode" --strip-components=1
    rm "$GOINFRE/vscode.tar.gz"
fi
ln -sf "$MY_APPS/vscode/bin/code" "$LOCAL_BIN/code"

# --- 3. CONDA (For Python Only) ---
if [ ! -d "$GOINFRE/miniconda3" ]; then
    echo "🐍 Installing Conda..."
    curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -u -p "$GOINFRE/miniconda3"
    rm /tmp/miniconda.sh
fi
ln -sfn "$GOINFRE/miniconda3" "$HOME/miniconda3"

# --- 4. DISCORD (WebCord AppImage) ---
# Updated to v4.12.1 with robust curl flags
if [ ! -f "$MY_APPS/discord.AppImage" ] || [ $(stat -c%s "$MY_APPS/discord.AppImage") -lt 1000 ]; then
    echo "💬 Installing Discord (WebCord)..."
    rm -f "$MY_APPS/discord.AppImage" # Remove if it's a tiny "Not Found" file
    curl -Lf "https://github.com/SpacingBat3/WebCord/releases/download/v4.12.1/WebCord-4.12.1-x64.AppImage" -o "$MY_APPS/discord.AppImage"
    chmod +x "$MY_APPS/discord.AppImage"
fi
# Shortcut and Config parts stay the same
echo -e "#!/bin/bash\nnohup $MY_APPS/discord.AppImage --no-sandbox > /dev/null 2>&1 &" > "$LOCAL_BIN/discord"
chmod +x "$LOCAL_BIN/discord"
# Link Config
mkdir -p "$HOME/.config"
mkdir -p "$GOINFRE/discord_config"
ln -sfn "$GOINFRE/discord_config" "$HOME/.config/WebCord"

# --- 5. PYCHARM (Community Edition) ---
if [ ! -f "$MY_APPS/pycharm/bin/pycharm.sh" ]; then
    echo "💎 Installing PyCharm..."
    mkdir -p "$MY_APPS/pycharm"
	curl -Lf "https://download.jetbrains.com/python/pycharm-community-2023.3.3.tar.gz" --output "$GOINFRE/pycharm.tar.gz"
    tar -xzf "$GOINFRE/pycharm.tar.gz" -C "$MY_APPS/pycharm" --strip-components=1
    rm "$GOINFRE/pycharm.tar.gz"
fi
echo -e "#!/bin/bash\nnohup $MY_APPS/pycharm/bin/pycharm.sh > /dev/null 2>&1 &" > "$LOCAL_BIN/pycharm"
chmod +x "$LOCAL_BIN/pycharm"
mkdir -p "$GOINFRE/pycharm_data"
ln -sfn "$GOINFRE/pycharm_data" "$HOME/.config/JetBrains"

# --- 5. NODE & NPM INSTALLER ---
if ! command -v node &> /dev/null; then
    echo "📦 Node.js not found. Installing via Conda..."
    # We include python=3.11 to ensure the environment stays on the version you want
    conda install -c conda-forge nodejs=20 python=3.11 -y
else
    echo "✅ Node.js is already installed. Skipping..."
fi

# Always ensure the npm prefix is set correctly to Goinfre
if command -v npm &> /dev/null; then
    mkdir -p "$MY_APPS/npm-global"
    npm config set prefix "$MY_APPS/npm-global"
    
    # Ensure this is in your PATH (Add this to your .zshrc if not already there)
    # export PATH="$MY_APPS/npm-global/bin:$PATH"
fi

# --- 4. THE PORTALS (Heavy Data to Goinfre) ---
echo "🔗 Opening Portals..."
mkdir -p "$HOME/.local/share" "$HOME/.local/state" "$HOME/.vscode"

# Link Neovim Data/State
ln -sfn "$GOINFRE/nvim_data" "$HOME/.local/share/nvim"
ln -sfn "$GOINFRE/nvim_state" "$HOME/.local/state/nvim"

# Link VS Code Extensions
ln -sfn "$GOINFRE/vscode_data" "$HOME/.vscode/extensions"

# --- 5. STANDALONE KITTY & FASTFETCH ---
# (Assuming you ran the install.sh once to put them in .local/bin)
# This part makes sure your .local/bin is always in your PATH
export PATH="$LOCAL_BIN:$PATH"

# --- 6. HOUSEKEEPING ---
rm -rf "$HOME/.local/lib/python3.10/site-packages/pydantic" 2>/dev/null
hash -r

echo "✅ GOINFRE READY. Ready to Rice."
