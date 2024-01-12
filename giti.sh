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
source $GITI_PATH/menu.sh
source $GITI_PATH/usage_guide.sh
source $GITI_PATH/commands/push.sh
source $GITI_PATH/commands/setup.sh
source $GITI_PATH/commands/fresh.sh
source $GITI_PATH/commands/remove.sh

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

IFS=' ' read -a Array <<<"$@"

for element in $(seq 0 ${#Array}); do
  case ${Array[$element]} in
    (-h|--help) usage_guide;;
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
    (-*|--*) echo "Invalid option: ${Array[$element]}" >&2;
             usage_guide
             exit 1;;
  esac
done

if [[ $# -eq 0 ]]; then
  usage_guide
else
  for option in $@; do
    case $option in
      (fresh) fresh_options;;
      (push) push_changes;;
      (remove) remove_options;;
      (setup) set_up;;
      (*) usage_guide;;
    esac
  done
fi
