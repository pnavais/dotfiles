#!/usr/bin/env bash

####################################################################################
# utils-config.sh
# ---------------
#
# Perform misc. utils installation
#
####################################################################################

# Globals
#########
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
BASH_MAIN="$SCRIPT_DIR/../bash";

# Functions
###########

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh
DELTA_THEMES_DIR="$HOME/.config/delta/"

showSection "Performing misc tools installation ";

showSubSection "Installing Zoxide";
if isLinux; then
	printf "$(pad "Fetching $(ansi --green \"Zoxide\")")";
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash &>/dev/null
	showResultOrExit;
fi

showSubSection "Configuring Git misc utils"
if isLinux; then
	mkdir -p $DELTA_THEMES_DIR
	printf "$(pad "Fetching $(ansi --green \"Delta\ themes\")")";
	curl -o ${DELTA_THEMES_DIR}/themes.gitconfig -sfL "https://raw.githubusercontent.com/dandavison/delta/master/themes.gitconfig"
	showResultOrExit;
fi

