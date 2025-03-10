#!/usr/bin/env bash

####################################################################################
# system-config.sh
# ----------------
#
# Perform system initialization.  Chezmoi and the repo are downloaded in a single
# operation and then nix-darwin rebuilds the whole system with the installed flake.
#
####################################################################################

# Globals
#########
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)
BASH_MAIN="$SCRIPT_DIR/../bash"
GITHUB_USERNAME="pnavais"

SUDO="sudo"

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

# Functions
###########

########### MAIN ################

showSection "Bootstrapping system"

showSubSection "Installing dotfiles"
pad "Initializing dotfiles with $(ansi -green chezmoi)"
if [[ ! -d "$CHEZMOI_HOME" ]]; then
  executeCmd "sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME $IO_REDIR"
else
  showResult 0 "(Skipped)"
fi

showSubSection "Installing dependencies"
pad "Building $(ansi -green nix-darwin) system"
NIX_DARWIN_INSTALL_CMD="darwin-rebuild switch"
executeCmd "${NIX_DARWIN_INSTALL_CMD}"
