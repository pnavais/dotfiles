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
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)
BASH_MAIN="$SCRIPT_DIR/../bash"

SUDO="sudo"

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

# Functions
###########

########### MAIN ################

showSection "Installing and configuring tools"

if isAvailable "mise"; then
  showSubSection "Processing Mise tools"
  printf "$(pad "Installing $(ansi --green \"Mise\") runtimes")"
  executeCmd "mise install $IO_REDIR"
fi

showSubSection "Configuring Misc utils"

# Install Tmux plugin manager
pad "Installing $(ansi --red-intense Tmux) plugin manager"
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  TMUX_INSTALL_CMD="git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm $IO_REDIR"
  executeCmd "${TMUX_INSTALL_CMD}"
else
  showResult 0 "(Skipped)"
fi

# Install Delta themes
DELTA_THEMES_DIR=${XDG_CONFIG_HOME:-~/.config}/delta
pad "Fetching $(ansi --blue Delta) themes"
if [[ ! -d "${DELTA_THEMES_DIR}" ]]; then
  mkdir -p ${DELTA_THEMES_DIR}
  DELTA_THEMES_CMD="curl -o ${DELTA_THEMES_DIR}/themes.gitconfig -sfL \"https://raw.githubusercontent.com/dandavison/delta/master/themes.gitconfig\" $IOREDIR"
  executeCmd "${DELTA_THEMES_CMD}"
else
  showResult 0 "(Skipped)"
fi
