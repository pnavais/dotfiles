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

SUDO="sudo"


# Functions
###########

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

if ! isARM64; then

showSection "Performing Java Customization";

if [ "$EUID" -ne 0 ]; then
	CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
	if [ ${CAN_I_RUN_SUDO} -eq 0 ]; then
		# Ask for the administrator password upfront
		warn "This script needs elevated permissions to execute.\nPlease provide super-user credentials to continue.\n"
		sudo -v
	fi

	# Keep-alive: update existing `sudo` time stamp until finished
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
else
	SUDO=""
fi

# Installing JVM Tools
showSubSection "Installing JVM tools";

if [[ ! -e "/usr/local/sdkman" ]]; then
	printf "$(pad "Installing $(ansi --green \"SDKMAN\!\")")";
	$SUDO bash -c "export SDKMAN_DIR=\"/usr/local/sdkman\" && curl -s \"https://get.sdkman.io\" | bash &>/dev/null";
	LAST_ERROR=$?
	if [ "$LAST_ERROR" -eq 0 ]; then
		$SUDO chown -R $USER:$GID /usr/local/sdkman
	else
		$(exit $LAST_ERROR) # Re-establish return code
	fi
	showResultOrExit;
fi

fi
