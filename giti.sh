#!/bin/bash

###########################################################################
# Uses an interactive menu and gets user inputs to format the git commits.
# It also handles the complete process of pulling, staging, committing,
# and pushing the code into the remote git server.
# -------------------------------------------------------------------------
# Author: Mohsen Karami
# Email: karami.mohsen@protonmail.com
###########################################################################

GITI_PATH=$( dirname $0 )
VERSION=0.5.3
# Ensure GITI_PATH is set correctly
if [ -z "$GITI_PATH" ]; then
    echo "Error: GITI_PATH is not set"
    exit 1
fi

# Verify required source files exist
for file in "$GITI_PATH/menu.sh" "$GITI_PATH/usage_guide.sh" "$GITI_PATH/commands/push.sh" "$GITI_PATH/commands/setup.sh" "$GITI_PATH/commands/fresh.sh" "$GITI_PATH/commands/remove.sh"; do
    if [ ! -f "$file" ]; then
        echo "Error: Required file $file not found"
        exit 1
    fi
done

source $GITI_PATH/menu.sh
source $GITI_PATH/usage_guide.sh
source $GITI_PATH/commands/push.sh
source $GITI_PATH/commands/setup.sh
source $GITI_PATH/commands/fresh.sh
source $GITI_PATH/commands/remove.sh

IFS=' ' read -a Array <<<"$@"

for element in $(seq 0 ${#Array}); do
  case ${Array[$element]} in
    (-h|--help) usage_guide $VERSION;;
    (-a|--append) APPEND=true;;
    (-i|--initial) INITIAL=true;;
    (-t|--tag) TAG=${Array[$element+1]};;
    (-m|--merge) MERGE=${Array[$element+1]};;
    (-r|--revise) REVISE=${Array[$element+1]};;
    (-b|--branch) BRANCH_NAME=${Array[$element+1]};;
    (-n|--name) NEW_BRANCH_NAME=${Array[$element+1]};;
    (-cb|--current-branch) CURRENT_BRANCH_NAME=true;;
    (--clear) CLEAR=true;;
    (--manual) MANUAL=true;;
    (--push) PUSH=true;;
    (--staged) STAGED=true;;
    (--temp) TEMPORARY=true;;
    (--hash) HASH=${Array[$element+1]};;
    (-v|--version) cat << EOF >&2
Giti - Version $VERSION
A powerful Git utility tailored to streamline your Git operations via a user-friendly interactive interface.

USAGE
  giti <command> [options] [arguments]

Get started by running: giti --help

Licensed under GPLv3
Source Code: https://github.com/mohsen-karami/giti

EOF
             exit 1;;
    (-*|--*) echo "Invalid option: ${Array[$element]}" >&2;
             usage_guide $VERSION
             exit 1;;
  esac
done

if [ ! -d .git ]; then
  echo "There is no git repository in the current directory."
  exit 2
fi

REPOSITORY=$(basename `git rev-parse --show-toplevel`)
BRANCH=$(git branch --show-current)

if [ -z "$(git status --porcelain)" ]; then 
  is_wd_clean=true
else 
  is_wd_clean=false
fi

if [[ $# -eq 0 ]]; then
  usage_guide $VERSION
  exit 0
else
  for option in "$@"; do
    case $option in
      (fresh) fresh_options;;
      (push) push_changes;;
      (remove) remove_options;;
      (setup) set_up;;
      (*) usage_guide $VERSION;;
    esac
  done
fi

# Add explicit exit at the end
exit 0