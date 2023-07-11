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

# Constants
REPOSITORY=$(basename `git rev-parse --show-toplevel`)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$(git status --porcelain)" ]; then 
  is_wd_clean=true
else 
  is_wd_clean=false
fi

# Check options
IFS=' ' read -a Array <<<"$@"

for element in $(seq 0 ${#Array}); do
  case ${Array[$element]} in
    (-h|--help) usage_guide;;
    (-r|--revise) REVISE=${Array[$element+1]};;
    (-*|--*) echo "Invalid option: ${Array[$element]}" >&2;
             usage_guide
             exit 1;;
  esac
done


generate_comment_label () {
  printf "\e[1;93mWhat have you done?\n\e[1;0m"
  task_options=("Added new features" "Fixed bugs" "Modified style components" "Implemented minor changes" "Improved the code performance" "Refactored the code" "Wrote some tests" "Updated the documents")
  select_option "${task_options[@]}"
  index=$?
  labels=("Feature: " "Fix: " "Style: " "Chore: " "Performance: " "Refactor: " "Test: " "Doc: ")
  label=${labels[$index]}
}

generate_comment_title () {
  index=1
  printf "\e[1;93mEnter your commit message:\n\e[0;90m"
  read -a title_array
  while [ -z ${title_array} ]; do
    ((index++))
    printf "\n\n\e[1;31mSorry, but the commit message is required.\e[0;39m\n"
    if (( index>3 )); then
      printf "\e[1;31mThe script has stopped running because the user refused to enter the commit message that is a required input.\e[0;39m\n"
      exit 2
    else
      printf "\e[1;93mEnter your commit message:\n\e[0;90m"
      read -a title_array
    fi
  done
  title=${title_array[*]}
  title="$(tr '[:lower:]' '[:upper:]' <<< ${title:0:1})${title:1}"
}


generate_comment_body () {
  printf "\e[1;93mLeave a description for your commit:\n\e[0;90m"
  printf "\e[1;94mThis is an optional input, press Enter to skip this step.\n\e[0;90m"
  printf "\e[1;94mYou can write a multi-line description by typing "'\\\\n'" anywhere you wish to start a new line in your note.\n\e[0;90m"
  read raw_description
  raw_description="${raw_description//" "/$'!$%*'}"
  raw_description="${raw_description//"\n"/\n$'\n'}"
  for element in $raw_description; do
    description+="$(tr '[:lower:]' '[:upper:]' <<< ${element:0:1})${element:1}"
  done
  description="${description//"!$%*"/$' '}"
  description="${description//"\n"/$'\n'}"
  printf "\e[1;93mIn case of using an issue tracker, provide the link below:\n\e[0;90m"
  printf "\e[1;94mThis is an optional input, press Enter to skip this step.\n\e[0;90m"
  read link
  if [ ! -z $link ]; then
    if [ ! ${link:0:4} == "http" ]; then
      link="https://"$link
    fi
    link="Reference: "$link
  fi
  if [[ ! -z $description ]] && [[ ! -z $link ]]; then
    body=$description$'\n\n'$link
  elif [[ ! -z $description ]] || [[ ! -z $link ]]; then
    body=$description$link
  fi
}


override_commits () {
  # show a warning message that inform the user about the danger of their process
  printf "\e[1;31mNote:\e[0;39m your current branch is \e[1m$BRANCH\e[0m, are you sure to continue?(y/n)"
  read agreement
  agreement=${agreement:-y}
  if [ $agreement == y ]; then
    if $is_wd_clean ; then
      # check if there are some new commits on the remote branch
      if [ $REVISE == 1 ]; then
        printf "\e[1;96mFetching the last commit from the remote server\n\e[0;90m"
      else
        printf "\e[1;96mFetching the last $REVISE commits from the remote server\n\e[0;90m"
      fi
      git reset HEAD~$REVISE
      generate_comment_label
      generate_comment_title
      title=$label$title
      generate_comment_body
      printf "\e[1;96mStaging the changes\n\n\e[0;90m"
      git add .
      line_break="-------------------------------------------------------"
      if [ -z "$body" ]; then
        printf "\n\e[1;96mCommiting your changes with the following message:\n$line_break\n\n\e[1;93m$title\n\e[0;90m"
        git commit -m "$title"
      else
        printf "\e[1;96mCommiting your changes with the following message and description:\n$line_break\n\n\e[38;5;69m$title\n\n\n\e[38;5;169m$body\n\e[0;90m"
        git commit -m "$title" -m "$body"
      fi
      printf "\e[1;96mPushing your commit \e[31mforcefully\e[96m into the \e[39m$BRANCH\e[96m branch of the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
      git push --force
    else
      printf "\e[1;1mPlease stash your changes or revert them before you override the previous commit(s)\n\e[0;90m"
    fi
  fi
}


stage_commit_push () {
  printf "\e[1;31mNote:\e[0;39m your current branch is \e[1m$BRANCH\e[0m, are you sure to continue?(y/n)"
  read agreement
  agreement=${agreement:-y}
  if [ $agreement == y ]; then
    if $is_wd_clean ; then
      printf "\e[1;1mNothing to commit, the working directory is clean\n\e[0;90m"
    else
      generate_comment_label
      generate_comment_title
      title=$label$title
      generate_comment_body
      printf "\e[1;96mStashing your current changes\n\e[0;90m"
      git stash --include-untracked
      printf "\e[1;96mPulling the latest changes of the \e[39m$BRANCH\e[96m branch\n\e[0;90m"
      git pull
      printf "\e[1;96mRestoring your stashed changes\n\e[0;90m"
      git stash pop
      printf "\e[1;96mStaging the changes\n\n\e[0;90m"
      git add .
      line_break="-------------------------------------------------------"
      if [ -z "$body" ]; then
        printf "\n\e[1;96mCommiting your changes with the following message:\n$line_break\n\n\e[1;93m$title\n\e[0;90m"
        git commit -m "$title"
      else
        printf "\e[1;96mCommiting your changes with the following message and description:\n$line_break\n\n\e[38;5;69m$title\n\n\n\e[38;5;169m$body\n\e[0;90m"
        git commit -m "$title" -m "$body"
      fi
      printf "\e[1;96mPushing your commit into the \e[39m$BRANCH\e[96m branch of the \e[39m$REPOSITORY\e[96m repository\n\e[0;90m"
      git push
    fi
  fi
}

push_changes() {
  if [[ -z $REVISE ]]; then
    stage_commit_push
  else
    if [ -z "${REVISE##*[!0-9]*}" ]; then
      echo "Invalid argument: must be an integer" >&2; exit 1 
    else
      override_commits
    fi
  fi
}

if [[ $# -eq 0 ]]; then
  usage_guide
else
  for option in $@; do
    case $option in
      (push) push_changes;;
      (*) usage_guide;;
    esac
  done
fi
