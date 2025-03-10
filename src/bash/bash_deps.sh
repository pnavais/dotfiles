#!/usr/bin/env bash

####################################################################################
# bash_deps.sh
# ------------
#
# Manages all bash needed external lib dependencies
#
####################################################################################

# Globals
#########
BASH_MAIN=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
BASH_LIB="$BASH_MAIN/lib";
BASH_DEPS="$BASH_MAIN/bash.pack";

# Imports
##########
source $BASH_MAIN/bash_common.sh

# Functions
###########

###################################
# Retrieves all external bash libs and
# keep them in the given directory
###################################
function loadBashLibs() {
	downloadLibs "$BASH_LIB" "$BASH_DEPS";
	sourceLibs "$BASH_LIB";
}

###################################
# Retrieves all external libs and
# keep them in the given directory
# Params:
#  - lib_dir   : Target directory to
#    store downloaded libs
#  - deps_file : Dependencies file
###################################
function downloadLibs() {
	local lib_dir=$1;
	local deps_file=$2;

	# Create bash lib dir
	createDir $lib_dir;
	show_sect=0;

	# Download dependencies
	while read line; do
		read -ra lib_data <<< "$line"
		regex="package '(.+)', name: \['([^]]+)'\], url: \['([^]]+)'\](, git: \['([^]]+)'\]){0,1}";
		if [[ $line =~ $regex ]]; then
			name=${BASH_REMATCH[1]};
			lib_name=${BASH_REMATCH[2]};
			url=${BASH_REMATCH[3]};
			use_git=0;
			if [[ "${BASH_REMATCH[4]}" =~ "git: ['true']" ]]; then
				use_git=1;
			fi

			# Download only if lib does not exist
			if [[ ! -e "${lib_dir}/${lib_name}" ]]; then
				if [[ $show_sect == 0 ]]; then showSubSection "Downloading dependencies"; show_sect=1; fi
				msg=$(pad "Downloading \"${name}\"");
				printf "$msg";
				if [[ $use_git -eq 0 ]]; then
					curl -o ${lib_dir}/${lib_name} -sfL $url 2>/dev/null
				else
					git clone $url ${lib_dir}/${lib_name} 2>/dev/null
				fi
				showResultOrExit;
			fi
		fi
	done < $deps_file
}

###################################
# Loads all external libraries
# in the given directory
# Params:
#  - lib_dir   : Target directory
#    with libs to load
###################################
function sourceLibs() {
	local lib_dir=$1;

	# Source all libs
	for lib in $(find $lib_dir/ -type f ); do
		source $lib;
	done;
}

loadBashLibs
