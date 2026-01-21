#!/bin/bash

# 1. KITTY INSTALLATION (Only if missing)
if [ ! -d "$HOME/.local/kitty.app" ]; then
    echo "Installing Kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
fi

# 2. FASTFETCH INSTALLATION (Only if missing)
if [ ! -f "$HOME/.local/bin/fastfetch" ]; then
    echo "Installing Fastfetch..."
    curl -L https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.tar.gz -o /tmp/fastfetch.tar.gz
    # Extract to a temp folder and move binary
    mkdir -p /tmp/ff_temp
    tar -xzf /tmp/fastfetch.tar.gz -C /tmp/ff_temp
    mv /tmp/ff_temp/*/usr/bin/fastfetch ~/.local/bin/fastfetch
    rm -rf /tmp/fastfetch.tar.gz /tmp/ff_temp
fi

# 3. DOTFILES SYNC
echo "Linking config files..."
rm -f ~/.zshrc ~/init_goinfre.sh # Remove old files/links first
ln -sf ~/school-config/.zshrc ~/.zshrc
ln -sf ~/school-config/init_goinfre.sh ~/init_goinfre.sh

# 4. GNOME EXTENSIONS
echo "Configuring GNOME Shell..."
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
# Only copy if extensions aren't already there
cp -rn "$HOME/school-config/extensions/"* "$HOME/.local/share/gnome-shell/extensions/"

# 5. DCONF SETTINGS
dconf load /org/gnome/shell/extensions/ < "$HOME/school-config/extension_settings.conf"
dconf load /org/gnome/desktop/ < "$HOME/school-config/gnome_desktop_settings.conf"

# 6. ENABLE EXTENSIONS
gsettings set org.gnome.shell enabled-extensions "[
  'forge@jmmaranan.com',
  'hidetopbar@mathieu.bidon.ca',
  'openbar@neuromorph',
  'search-light@icedman.github.com',
  'soft-brightness@fifi.org',
  'tiling-assistant@leleat-on-github',
  'unite@hardpixel.eu',
  'vertical-workspaces@G-dH.github.com'
]"

echo "✅ Setup Complete! Please log out and back in for GNOME changes."




# --For toggle activatons conda
#conda config --set auto_activate_base false
