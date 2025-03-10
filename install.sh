#!/usr/bin/env bash

#############################
# Payball Dotfiles v2
# (c) Pablo Navais, 2025
#############################

# Globals
#########
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
BASH_MAIN="$SCRIPT_DIR/src/bash";

VERSION="1.0.0";
EMAIL="pnavais@hotmail.com"
AUTHOR="Pablo Navais"
YEAR="2025"

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh
CURL_CMD="curl"

# Functions
###########

#######################################
# Checks prerequisites for the
# installation
#######################################
function checkPrerequisites() {
   # Check basic commands
   if ! isAvailable $CURL_CMD; then
      printf "${RED}[check failed]: \"${CURL_CMD}\" command could not be found${NC}"
      exit 1
   fi
}

########### MAIN ################

trap ctrl_c INT

export VERBOSE=0
PARAMS=""

# Parse options
while (( "$#" )); do
	case "$1" in
		--help)
			show_help;
			exit 0;
			;;
		-V|--version)
			show_version;
			exit 0;
			;;
		-v|--verbose)
			VERBOSE=1;
			shift 1
			;;
		--) # end argument parsing
			shift
			break
			;;
		*) # preserve positional arguments
			PARAMS="$PARAMS $1"
			shift
			;;
	esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

[[ $VERBOSE -eq 0 ]] && export IO_REDIR="&> /dev/null" || export IO_REDIR=""

showBanner
checkSudo

checkPrerequisites
showSection 'Environment preparation'

if isOSX; then
  $SCRIPT_DIR/src/system/osx/install.sh
elif isWSL; then
  printf "TODO: WSL installation pending"
elif isLinux; then
  printf "TODO: Linux installation pending"
else
  fail "System not supported"
fi


# Perform specific tools post-install config
OLD_IFS=$IFS;
IFS=$'\n';
for config in $(find $SCRIPT_DIR/ -name "*-config.sh"); do
	source $config;
done

addInstallNote "\nInstallation finished."
printNotes
showExitMsg

#showSubSection "Configuring Misc utils"

# Install Tmux plugin manager
# pad "Installing Tmux plugin manager"
# if [ ! -d $HOME/.tmux/plugins/tpm ]; then
	# TMUX_INSTALL_CMD="git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm $IO_REDIR"
	# executeCmd "${TMUX_INSTALL_CMD}"
# else
  # showResult 0 "(Skipped)"
# fi

# Install Delta themes
# DELTA_THEMES_DIR=${XDG_CONFIG_HOME:-~/.config}/delta
# pad "Fetching Delta themes"
# if [[ ! -d "${DELTA_THEMES_DIR}" ]]; then
  # mkdir -p ${DELTA_THEMES_DIR}
	# DELTA_THEMES_CMD="curl -o ${DELTA_THEMES_DIR}/themes.gitconfig -sfL \"https://raw.githubusercontent.com/dandavison/delta/master/themes.gitconfig\" $IOREDIR"
	# executeCmd "${DELTA_THEMES_CMD}"
# else
  # showResult 0 "(Skipped)"
# fi
