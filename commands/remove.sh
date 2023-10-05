#!/bin/bash

remove_branch() {
  [[ $REMOVE_BRANCH ]] && BRANCH=$REMOVE_BRANCH
  printf "\e[1;31mNote:\e[0;39m you're gonna remove the \e[1m$BRANCH\e[0m branch, are you sure to continue?(y/n)"
  read confirm
  confirm=${confirm:-y}
  if [ $confirm == y ]; then
    if [[ $REMOVE_CURRENT_BRANCH ]]; then
      printf "\e[1;96mSwitch to the branch \e[1mmaster\e[0m.\n\e[0;90m"
      git checkout master
    fi
    printf "\e[1;96mRemove the branch on your local machine.\n\e[0;90m"
    git branch -D $BRANCH
    printf "\e[1;96mRemove the branch on your remote server.\n\e[0;90m"
    git push origin :$BRANCH
  fi
}


remove_options() {
  if [[ $REMOVE_CURRENT_BRANCH ]] || [[ $REMOVE_BRANCH ]]; then
    [[ $REMOVE_BRANCH == $BRANCH ]] && REMOVE_CURRENT_BRANCH=true
    remove_branch
  else
    usage_guide
    exit 1
  fi
  exit 0
}
