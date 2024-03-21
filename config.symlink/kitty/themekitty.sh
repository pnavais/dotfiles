#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/kitty/themes"
TARGET_FILE="$HOME/.config/kitty/theme.conf"

theme_name=$(fd . -e conf "$THEMES_DIR" -x basename | sed -e "s/.conf//g" | fzf --prompt "󰬒  Kitty theme: " --height=50% --layout=reverse --border --exit-0)
theme=${THEMES_DIR}"/"${theme_name}".conf"

ln -fs $theme $TARGET_FILE
