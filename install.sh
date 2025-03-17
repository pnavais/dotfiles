#!/usr/bin/env bash

#############################
# Payball Dotfiles v2
# (c) Pablo Navais, 2025
#############################

# Globals
#########
INSTALL_DIR=$(mktemp -d -u --suffix dotfiles.tmp)
[[ -n "${BASH_SOURCE[0]}" ]] && SCRIPT_DIR=$(
  cd "$(dirname ${BASH_SOURCE[0]})"
  pwd
) || SCRIPT_DIR=$INSTALL_DIR
BASH_MAIN="$SCRIPT_DIR/src/bash"
DOTFILES_REPO="https://github.com/pnavais/dotfiles"

VERSION="1.0.0"
EMAIL="pnavais@hotmail.com"
AUTHOR="Pablo Navais"
YEAR="2025"

CURL_CMD="curl"
GIT_CMD="git"

# Functions
###########

#######################################
# Checks prerequisites for the
# installation
#######################################
function checkPrerequisites() {
  commands=("$CURL_CMD" "$GIT_CMD")
  # Check basic commands
  for cmd in "${commands[@]}"; do
    if ! hash "$cmd" &>/dev/null; then
      printf "\e[31m[check failed]: \"%s\" command could not be found$\e[0m" "$cmd"
      exit 1
    fi
  done

  # Check if we are inside the target repo and install files are there
  inside_repo=0
  missing_files=()
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo_url=$(git remote get-url origin)
    if [[ "${repo_url,,}" =~ github.com[:|/]pnavais/dotfiles.git ]]; then
      inside_repo=1
      while read -r file; do
        if [[ ! -f "$file" ]]; then
          missing_files+=("$file")
        fi
      done < <(git ls-tree -r HEAD --name-only src/ patches/)
    fi
  fi

  if [[ $inside_repo -eq 1 ]]; then
    # Recover missing files
    for missing_file in "${missing_files[@]}"; do
      printf "\e[32m=>\e[0m Reverting missing file \e[34m[%s]\e[0m\n" "$missing_file"
      git checkout HEAD -- "$missing_file"
    done
  else
    # Fech full repo in temp directory
    SCRIPT_DIR=$INSTALL_DIR
    BASH_MAIN="$SCRIPT_DIR/src/bash"
    printf "\e[32m=>\e[0m Downloading resources\e[0m\n"
    git clone $DOTFILES_REPO "$INSTALL_DIR" &>/dev/null
  fi
}

#######################################
# Perform cleanup of leftover resources
#######################################
function cleanup() {
  # Do cleanup of temp files
  if [[ -d "$INSTALL_DIR" ]]; then
    rm -fr "$INSTALL_DIR" &>/dev/null
  fi
}

#######################################
# Displays script syntax help
#######################################
function show_help() {
  printf "\e[33mPayball's Dotfiles\e[0m automated installer\n"
  printf "%s <%s>, %s\n\n" "$AUTHOR" "$EMAIL" "$YEAR"
  printf "Usage : %s <OPTIONS>\n" $(basename "$0")
  printf "where OPTIONS are :\n"
  printf "\t-v             : enables verbose mode\n"
  printf "\t-V|--version   : displays version\n"
  printf "\t-h|--help      : show this help\n"
}

#######################################
# Displays script version
#######################################
function show_version() {
  printf "v%s\n" $VERSION
}

########### MAIN ################

export VERBOSE=0
PARAMS=""

# Parse options
while (("$#")); do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -V | --version)
    show_version
    exit 0
    ;;
  -v | --verbose)
    VERBOSE=1
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

checkPrerequisites

# Imports
##########
source $BASH_MAIN/bash_common.sh
source $BASH_MAIN/bash_deps.sh

trap 'cleanup; ctrl_c;' INT

showBanner
checkSudo

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
OLD_IFS=$IFS
IFS=$'\n'
for config in $(find $SCRIPT_DIR/ -name "*-config.sh"); do
  source $config
done

addInstallNote "\nInstallation finished."
printNotes
showExitMsg

cleanup
