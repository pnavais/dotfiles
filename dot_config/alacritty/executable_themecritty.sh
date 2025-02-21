#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/alacritty/themes"
CONFIG_FILE="$HOME/.config/alacritty/alacritty.toml"
CURRENT_THEME="$HOME/.config/alacritty/current_theme.toml"

theme_name=$(fd . -e toml "$HOME/.config/alacritty/themes" -x basename | sed -e "s/.toml//g" | fzf --prompt "󰬈  Alacritty theme: " --height=50% --layout=reverse --border --exit-0)

if [ -n "$theme_name" ]; then
	theme=${THEMES_DIR}"/"${theme_name}".toml"
	ln -fs $theme $CURRENT_THEME
	touch $CONFIG_FILE
fi
