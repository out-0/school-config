#!/bin/bash

# Define paths
WP_DIR="$HOME/school-config/Wallpapers"
THEME_FILE="$HOME/school-config/kitty_themes.txt"

if [ -f "$THEME_FILE" ]; then
    # 1. Pick a random theme
    CHOSEN_THEME=$(shuf -n 1 "$THEME_FILE")
    
    # 2. Apply Kitty Theme
    kitten themes --reload-in=all "$CHOSEN_THEME"

    # 3. Match Wallpaper to Theme
    case "$CHOSEN_THEME" in
        "Cyberpunk Neon")
            WALLPAPER="neon.jpg"
            ;;
        "Sakura Night")
            WALLPAPER="sakura_trees.png"
            ;;
        "1984 Dark")
            WALLPAPER="shinobo.png"
            ;;
        *)
            # Default wallpaper if theme isn't specifically mapped
            WALLPAPER="default_cyber.png"
            ;;
    esac

    # Using absolute path for aarid
	# specifying the target wallpaper
    WP_PATH="$WP_DIR/$WALLPAPER"

    # 4. Apply to Xresources (for ft_lock)
    if [ -f "$WP_PATH" ]; then
        echo "ft_lock.image_file: $WP_PATH" | xrdb -merge
    fi
	
    # 5. Apply to GNOME Desktop (Optional - if you want desktop bg to match too)
    if [ -f "$WP_PATH" ]; then
        gsettings set org.gnome.desktop.background picture-uri "file://$WP_PATH"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WP_PATH"
    fi
fi
