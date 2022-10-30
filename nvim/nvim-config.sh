#!/usr/bin/env bash

####################################################################################
# java-config.sh
# --------------
#
# Perform additional Java configuration
#
####################################################################################

# Globals
#########
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
BASH_MAIN="$SCRIPT_DIR/../bash";
NEOVIM_CONFIG_PATH=$HOME/.config/nvim

# Functions
###########

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

showSection "Performing Neovim Customization";

# Tunning Terminfo
showSubSection "Installing custom configuration";
#if isOSX; then
	printf "$(pad "Installing $(ansi --green \"Neovim\ profile\")")";
	mkdir -p $NEOVIM_CONFIG_PATH && ln -fs $SCRIPT_DIR/init.lua $NEOVIM_CONFIG_PATH/
    showResultOrExit;
#fi
