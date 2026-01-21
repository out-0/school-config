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
