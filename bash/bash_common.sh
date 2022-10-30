#!/usr/bin/env bash

####################################################################################
# bash_common.sh
# --------------
#
# Contains globals and utility methods
#
####################################################################################

# Globals
#########

RES_OK="\xE2\x9C\x94"   #"\u2714";
RES_FAIL="\xE2\x9C\x96" #"\u2716";
RES_WARN="\xE2\x9A\xA0" #"\u2716";

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
WHITE="$(tput setaf 7)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

# Functions
###########

###################################
# Shows the banner
###################################
function showBanner() {
	printf "\n";
	printf "${GREEN},---- [${BOLD}${WHITE} v $VERSION ${NORMAL}${GREEN}]\n";
	printf "|     ____              __          _____\n";
	printf "|    / __ \____ ___  __/ /_  ____ _/ / ( )_____\n";
	printf "|   / /_/ / __ \`/ / / / __ \/ __ \`/ / /|// ___/\n";
	printf "|  / ____/ /_/ / /_/ / /_/ / /_/ / / /  (__  )\n";
	printf "| /_/    \__,_/\__, /_.___/\__,_/_/_/  /____/\n";
	printf "|             /____/\n";
	printf "|     ____        __  _____ __\n";
	printf "|    / __ \____  / /_/ __(_) /__  _____\n";
	printf "|   / / / / __ \/ __/ /_/ / / _ \/ ___/\n";
	printf "|  / /_/ / /_/ / /_/ __/ / /  __(__  )\n";
	printf "| /_____/\____/\__/_/ /_/_/\___/____/\n";
	printf "|\n";
	printf "| ${YELLOW}Pablo Navais (2017)  ${BOLD}${WHITE}<pnavais@gmail.com>${NORMAL}${GREEN}\n"
	printf "\`----\n${NORMAL}";
}

###################################
# Shows the exit message
###################################
function showExitMsg() {
	local msg="That's all Folks !";
	if isAvailable "toilet" && isAvailable "lolcat"; then
		printf $(toilet -f pagga "$msg")"\n\n" | lolcat;
	else
		printf "${GREEN}$msg${NORMAL}\n\n";
	fi
}

###################################
# Shows the Notes array
###################################
function printNotes() {
	printf "\n";
	local var=$( IFS=$'\n'; echo "${INSTALL_NOTES[*]}" );
	if isAvailable "boxes"; then
		debug "$(printf "$var" | boxes -d stone)";
	else
		debug "$(printf "$var")";
	fi
	printf "\n\n";
}

###################################
# Adds the given install note
# to the global array
# Exports:
# INSTALL_NOTES : The notes array
###################################
function addInstallNote() {
	INSTALL_NOTES+=("$1");
	if [[ ! $(declare -p INSTALL_NOTES | grep "^export") ]]; then
		export INSTALL_NOTES;
	fi
}

###################################
# Shows a heading section
# Params:
# - (1) section : Section's name
###################################
function showSection() {
	printf "\n\e[1;34m==> \e[1;37m$1\e[0m\n";
}

###################################
# Shows a sub section
# Params:
# - (1) subsection : Subsection's name
###################################
function showSubSection() {
	printf "\n\e[1;32m==> \e[1;37m$1\e[0m\n";
}

###################################
# Shows the result of an operation
###################################
function showResult() {
	local err=${1-$?};
	if [[ $err -eq 0 ]]; then
		success "$RES_OK\n";
	else
		fail "$RES_FAIL\n";
	fi
}

###################################
# Shows the result of an operation
# and exit if return code not 0
###################################
function showResultOrExit() {
	local err=$?;
	showResult $err;
	if [[ $err -ne 0 ]]; then
		exit -1;
	fi
}

#######################################
# Shows a success message (Green color)
# Params:
# - (1) msg : String to show
#######################################
function success() {
	printf "\e[0;32m$1\e[0m";
}

#######################################
# Shows a fail message (Red color)
# Params:
# - (1) msg : String to show
#######################################
function fail() {
	printf "\e[0;31m$1\e[0m";
}

#######################################
# Shows a debug message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function debug() {
	printf "\e[0;33m$1\e[0m";
}

#######################################
# Shows a warning message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function warn() {
	debug "$1"
}

##############################################
# Pads a message with the given character
# up to a maximum size,
# Params:
#   - (1) msg          : The message to pad
#   - (2) max_padding  : The maximum length to pad
#   - (3) padding_char : The character used in
#                        the padding.
##############################################
function paddingMax() {
	local msg=$1;
	local max_padding=$2;
	local padding_char=$3;
	local stripped_msg=$(stripAnsi "$msg");
	local cur_size=${#stripped_msg};

	while [ $cur_size -lt $max_padding ]; do
		let cur_size+=1;
		msg=${msg}${padding_char};
	done

	echo "$msg";
}

##############################################
# Pads a message with the given character
# up to the percentage of maximum terminal
# available width.
#
# params:
#   - (1) msg          : the message to pad
#   - (2) width_ratio  : the width percentage
#   - (3) padding_char : the character used in
#                        the padding.
##############################################
function padding() {
	local msg=$1;
	local width_ratio=$2;
	local padding_char=$3;
	local stripped_msg=$(stripAnsi "$msg");
	local cur_size=${#stripped_msg};
	local max_width=$(tput cols);
	local max_padding=$((max_width*width_ratio/100));

	while [ $cur_size -lt $max_padding ]; do
		let cur_size+=1;
		msg=${msg}${padding_char};
	done

	echo "$msg";
}

##############################################
# Pads a message with the given characters
# up to the percentage of maximum terminal
# available width.
#
# params:
#   - (1) msg          : the message to pad
##############################################
function pad() {
	padding "$1" 80 '.';
}

##############################################
# Removes ANSI sequences from a given String
# Params:
# - (1) msg : String to remove ANSI sequences
##############################################
function stripAnsi() {
	echo -e $1 | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g";
}

#######################################
# Retrieves the maximum number of lines
# from a given text input .
# Note: This function is intended to be used
# piped to stdout.
#######################################
function getMaxLines() {
	awk '{ if (length($0) > max) {max = length($0);} } END { print max }';
}

#######################################
# Tries to create the given directory
# only if it does not exist
# Params:
# - (1) dir : the directory to create
#######################################
function createDir() {
	local dir=$1;
	if [ ! -d "$dir" ]; then
		mkdir -p "$dir";
	fi
}

#######################################
# Creates links from a given array of
# files/directories in the home directory
# Params:
# - (1) links : the array of files/dirs
#######################################
function createLinks() {
	local links=(${@});
	local OLD_IFS=IFS;
	IFS=$'\n';

	for link in "${links[@]}"; do
		local file_name=$(basename $link);
		local target="$HOME/.${file_name/\.symlink/}";
		if [[ -f $link ]]; then color="yellow"; else color="blue"; fi
		printf $(pad "Creating symlink \"$(ansi --$color $target)\"");
		ln -sfn $link $target;
		showResult;
	done
	IFS=$OLD_IFS;
}

#######################################
# Checks if array of strings contains
# a given value
# Params:
# - (1) arr : the array of strings
# passed by name
#  (2) seeking: the element to search
#######################################
function arrayContains() {
	local str_arr_name=$1[@];
	local str_arr=("${!str_arr_name}");
	local seeking=$2;
	local in=1;

	for element in "${str_arr[@]}"; do
		if [[ $element == $seeking ]]; then
			in=0
			break
		fi
	done

	return $in
}

#######################################
# Checks if we are running on Mac OS X
#######################################
function isOSX() {
	[[ $OSTYPE =~ ^darwin ]] && return 0 || return 1;
}

#######################################
# Checks if we are running on ARM64
#######################################
function isARM64() {
	[[ $(uname -m) =~ ^aarch64$ ]] && return 0 || return 1;
}

#######################################
# Checks if an app is available
# Param:
#    - appName : Name of the app
#######################################
function isAvailable() {
	$(hash $1 &>/dev/null);
	[[ $? -eq 0 ]] && return 0 || return 1;
}

#######################################
# Creates a backup of the files and
# directories to be replaced
#######################################
#function backupDotfiles() {
	#local files=(${@});
	#local OLD_IFS=IFS;
	#IFS=$'\n';

	#for link in "${links[@]}"; do
		#local file_name=$(basename $link);
		#local target="$HOME/.${file_name/\.symlink/}";
		#if [[ -f $link ]]; then color="yellow"; else color="blue"; fi
		#printf $(pad "Creating symlink \"$(ansi --$color $target)\"");
		#ln -sfn $link $target;
		#showResult;
	#done
	#IFS=$OLD_IFS;
#}
