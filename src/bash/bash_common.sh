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

RES_OK="\xE2\x9C\x94"   #"\u2714"
RES_FAIL="\xE2\x9C\x96" #"\u2716"
RES_WARN="\xE2\x9A\xA0" #"\u2716"

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
WHITE="\e[37m"

BOLD_RED="\e[1;31m"
BOLD_GREEN="\e[1;32m"
BOLD_YELLOW="\e[1;33m"
BOLD_BLUE="\e[1;34m"
BOLD_WHITE="\e[1;37m"
NC="\e[0m"

#RED="$(tput setaf 1)"
#GREEN="$(tput setaf 2)"
#YELLOW="$(tput setaf 3)"
#BLUE="$(tput setaf 4)"
#WHITE="$(tput setaf 7)"
#BOLD="$(tput bold)"
#NORMAL="$(tput sgr0)"

# Functions
###########

###################################
# Shows the banner
###################################
function showBanner() {
  printf "\n${GREEN},---- [${BOLD_WHITE} v${VERSION} ${NC}${GREEN}]\n"
  printf "|     ____              __          _____\n"
  printf "|    / __ \____ ___  __/ /_  ____ _/ / ( )_____\n"
  printf "|   / /_/ / __ \`/ / / / __ \/ __ \`/ / /|// ___/\n"
  printf "|  / ____/ /_/ / /_/ / /_/ / /_/ / / /  (__  )\n"
  printf "| /_/    \__,_/\__, /_.___/\__,_/_/_/  /____/\n"
  printf "|             /____/\n"
  printf "|     ____        __  _____ __\n"
  printf "|    / __ \____  / /_/ __(_) /__  _____\n"
  printf "|   / / / / __ \/ __/ /_/ / / _ \/ ___/\n"
  printf "|  / /_/ / /_/ / /_/ __/ / /  __(__  )\n"
  printf "| /_____/\____/\__/_/ /_/_/\___/____/\n"
  printf "|\n"
  printf "| ${YELLOW}${AUTHOR} (${YEAR})  ${BOLD_WHITE}<${EMAIL}>${NC}\n"
  printf "\n"
}

###################################
# Shows the exit message
###################################
function showExitMsg() {
	local msg="That's all Folks !";
	if isAvailable "toilet" && isAvailable "lolcat"; then
		printf "$(toilet -f pagga "$msg")\n" | lolcat;
	else
		printf "${GREEN}$msg${NORMAL}\n\n";
	fi
}

###################################
# Shows the installation notes
###################################
function printNotes() {
	local var=$( IFS=$'\n'; echo "Notes: \n${INSTALL_NOTES[*]}" );
	if isAvailable "boxes"; then
		debug "\n$(printf "$var" | boxes -d stone)";
	else
		debug "\n$(printf "$var")";
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
  printf "\n${BOLD_BLUE}==> ${BOLD_WHITE}$1${NC}\n"
}

###################################
# Shows a sub section
# Params:
# - (1) subsection : Subsection's name
###################################
function showSubSection() {
  printf "\n${BOLD_GREEN}==> ${BOLD_WHITE}$1${NC}\n"
}

###################################
# Shows the result of an operation
###################################
function showResult() {
	local err=${1-$?}
        LAST_RESULT=$err
        local msg=$2
        local verbosity=${3-$VERBOSE}
        local msg_ok=$RES_OK
        local msg_fail=$RES_FAIL

	[[ $verbosity -ne 0 ]] && msg_ok="\n\n${BOLD_GREEN}Command executed succesfully${NC}"
	[[ $verbosity -ne 0 ]] && msg_fail="\n\n${BOLD_RED}Command failed${NC}" 

	if [[ $err -eq 0 ]]; then
		success "$msg_ok"
		if [ -n "$msg" ]; then
			warn " $msg"
		fi
		printf "\n"
	else
		fail "$msg_fail\n"
	fi
}

###################################
# Shows the result of an operation
# and exit if return code not 0
###################################
function showResultOrExit() {
  local err=$?
  LAST_RESULT=$err
	local msg=$1
  local verbosity=${2-$VERBOSE}
	showResult $err "$msg" $verbosity
	if [[ $err -ne 0 ]]; then
		if [ -n "$msg" ]; then
			fail "$msg\n"
		fi
		exit -1
	fi
}

#######################################
# Shows a success message (Green color)
# Params:
# - (1) msg : String to show
#######################################
function success() {
  printf "${GREEN}$1${NC}"
}

#######################################
# Shows a fail message (Red color)
# Params:
# - (1) msg : String to show
#######################################
function fail() {
  printf "${RED}$1${NC}"
}

#######################################
# Shows a debug message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function debug() {
  printf "${YELLOW}$1${NC}"
}

#######################################
# Shows a warning message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function warn() {
  printf "${BOLD_YELLOW}$1${NC}"
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
	local msg=$1
	local max_padding=$2
	local padding_char=$3
	local stripped_msg=$(stripAnsi "$msg")
	local cur_size=${#stripped_msg}

	while [ $cur_size -lt $max_padding ]; do
		let cur_size+=1
		msg=${msg}${padding_char}
	done

	echo -n "$msg"
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
    local msg=$1
    local width_ratio=$2
    local padding_char=$3
    local stripped_msg=$(stripAnsi "$msg")
    local cur_size=${#stripped_msg}
    local max_width=$(tput cols)
    local max_padding=$((max_width*width_ratio/100))
    	
    while [ $cur_size -lt $max_padding ]; do
        let cur_size+=1
        msg=${msg}${padding_char}
    done
    echo -ne "$msg"
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
# Checks if we are running on WSL
#######################################
function isWSL() {
    [[ $(uname -r) =~ ^Microsoft ]] && return 0 || return 1
}

#######################################
# Checks if we are running on ARM64
#######################################
function isARM64() {
    [[ $(uname -m) =~ ^(aarch64|arm64)$ ]] && return 0 || return 1
}

#######################################
# Checks if we are running on Linux
#######################################
function isLinux() {
    [[ $OSTYPE =~ ^linux ]] && return 0 || return 1;
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
# Checks if running using super use
# and asks for permissions if not
#######################################
function checkSudo() {
   # Check sudo permissions
   if [ "$EUID" -ne 0 ]; then
     CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
     if [ ${CAN_I_RUN_SUDO} -eq 0 ]; then
       # Ask for the administrator password upfront
       warn "This script needs elevated permissions to execute.\nPlease provide super-user credentials to continue.\n"
       sudo -v
     fi
       # Keep-alive: update existing `sudo` time stamp until finished
       while true; do sudo -n true; sleep 62; kill -0 "$$" || exit; done 2>/dev/null &
     else
       SUDO=""
   fi
}
 
#######################################
# Draws an horizontal line
#######################################
function drawSeparator() {
	if [[ $VERBOSE != 0 ]]; then
    [[ ${1:0} -eq 0 ]] && CR="\n" || CR=""
    printf "${CR}%*s\n" "${COLUMNS:-$(tput cols)}" '' | tr ' ' '#'
  fi
}

#######################################
# Runs a given command with
# and asks for permissions if not
#######################################
function run() {
  local show=${1-$VERBOSE}
  if [[ $show -ne 0 ]]; then
    v=$(exec 2>&1 && set -x && set -- "$@")
    "$@" 
  else
    "$@" >/dev/null 2>&1
  fi
}

#######################################
# Checks if running using super use
# and asks for permissions if not
#######################################
function executeCmd() {
	drawSeparator
	eval "$1"
  showResultOrExit
  drawSeparator 1
}

##############################################
# Captures the Ctrl-C
##############################################
function ctrl_c() {
  fail "Aborting execution\n"
  exit 1
}

##############################################
# Shows the help message
##############################################
function show_help() {
	debug "\nPayball's Dotfiles automated installer\n\n";
	printf "Usage : $(basename $0) <OPTIONS>\n";
	printf "where OPTIONS are :\n";
	printf "\t-v|--verbose : displays extended command & log messages\n";
	printf "\t-V|--version : show version\n";
	printf "\t--help       : show this help\n";
}

##############################################
# Shows the version
##############################################
function show_version() {
	success "v$VERSION\n";
	exit 0;
}
