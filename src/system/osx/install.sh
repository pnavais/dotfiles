#!/usr/bin/env bash

####################################################################################
# install.sh
# ----------
#
# Perform installation on Mac OSX
#
####################################################################################

# Globals
#########
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
BASH_MAIN="$SCRIPT_DIR/../../bash";

NIX_PROFILE_DIR="/nix/var/nix/profiles/default/etc/profile.d/"
NIX_CONF_DIR="$HOME/.config/nix"
NIX_DARWIN_CONF_DIR="/etc/nix-darwin"
NIX_DARWIN_FLAKE="$NIX_DARWIN_CONF_DIR/flake.nix"
NIX_CMD="nix"

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

########### MAIN ################

showSection "Performing Mac OSX installation";

pad "Installing Nix"
if ! isAvailable $NIX_CMD; then
   # Install Nix through Determinate Nix installer
   NIX_INSTALL_CMD="curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm $IO_REDIR"
   executeCmd "${NIX_INSTALL_CMD}"
   pad "Starting Nix daemon"
   if [[ -e "$NIX_PROFILE_DIR/nix-daemon.sh" ]]; then
       source "$NIX_PROFILE_DIR/nix-daemon.sh"
   else
      MSG="Nix daemon script not found"
      LAST_RESULT=1
   fi

   if [[ $LAST_RESULT -eq 0 ]]; then
      MSG=$($NIX_CMD --version)
      pad "Starting Nix"
   fi
   (exit $LAST_RESULT)
   showResultOrExit "($MSG)" 0
else 
   MSG=$(TERM=dumb && $NIX_CMD --version)
   showResultOrExit "(Skipped: $MSG)" 0
fi

if ! isAvailable $NIX_DARWIN_CMD; then
  NIX_DARWIN_INSTALL_CMD="nix run nix-darwin/master#darwin-rebuild -- switch $IO_REDIR"
  executeCmd "${NIX_DARWIN_INSTALL_CMD}"
fi

pad "Installing Xcode command line tools"
# Check if Xcode Command Line Tools are installed
MSG=$(xcode-select -p)
if [[ -n $MSG ]]; then
   showResultOrExit "(Skipped: Already installed)" 0
else
  # Find the correct package for installation
  PROD=$(softwareupdate -l 2>/dev/null | grep "\*.*Command Line Tools" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
    
  # Install the tools
  if [[ -n "$PROD" ]]; then
    #xcode-select --install
    executeCmd "softwareupdate -i \"$PROD\" --verbose $IO_REDIR"
  else
    MSG="No Command Line Tools package found for installation."
    showResultOrExit "(Skipped: $MSG)" 0
  fi
fi

pad "Installing Rosetta"
$(arch -x86_64 /usr/bin/true >/dev/null 2>&1 $IO_REDIR);
if [[ $? -eq 0 ]]; then
  showResultOrExit "(Skipped: Already installed)" 0
else
  executeCmd "echo \"A\n\" | softwareupdate --install-rosetta $IO_REDIR"
fi
