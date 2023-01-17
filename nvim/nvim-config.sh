#!/usr/bin/env bash

####################################################################################
# nvim-config.sh
# --------------
#
# Perform Neovim installation
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

showSubSection "Installing package manager";
printf "$(pad "Fetching $(ansi --green \"Packer\")")";
git clone --depth 1 "https://github.com/wbthomason/packer.nvim"\
	"$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" &>/dev/null
showResultOrExit;

showSubSection "Fetching plugins"
printf "$(pad "Fetching $(ansi --green \"Packer\ plugins\")")";
nvim -u $SCRIPT_DIR/init-install.lua --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
showResultOrExit;

# Tunning Neovim config
showSubSection "Installing custom configuration";
#if isOSX; then
	printf "$(pad "Installing $(ansi --green \"Neovim\ profile\")")";
	mkdir -p $NEOVIM_CONFIG_PATH && ln -fs $SCRIPT_DIR/init.lua $NEOVIM_CONFIG_PATH/
    showResultOrExit;
#fi

