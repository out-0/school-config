#!/bin/bash
# ----------Random Cyberpunk Theme Picker
THEME_FILE="$HOME/school-config/kitty_themes.txt"

if [ -f "$THEME_FILE" ]; then
    # Pick one random line
    CHOSEN_THEME=$(shuf -n 1 "$THEME_FILE")
    # Apply it instantly to this window
    kitten themes --reload-in=all "$CHOSEN_THEME"
fi
