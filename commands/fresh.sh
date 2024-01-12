#!/bin/bash

new_branch() {
  if [[ ! $BRANCH_NAME ]] || [[ $BRANCH_NAME == $BRANCH ]]; then
    CURRENT_BRANCH_NAME=true
  else
    BRANCH=$BRANCH_NAME
  fi
  printf "\e[1;31mNote:\e[0;39m you're gonna create a new branch named \e[1m$NEW_BRANCH_NAME\e[0m from the \e[1m$BRANCH\e[0m branch, are you sure to continue?(y/n)"
  read confirm
  confirm=${confirm:-y}
  if [ $confirm == y ]; then
    if [[ ! $CURRENT_BRANCH_NAME ]]; then
      git checkout $BRANCH
    fi
    printf "\e[1;96mCreate the \e[1;1m$NEW_BRANCH_NAME\e[1;96m branch and switch to it\n\e[0;90m"
    git checkout -b $NEW_BRANCH_NAME
    printf "\e[1;96mPush the \e[1;1m$NEW_BRANCH_NAME\e[1;96m branch and set the remote as upstream\n\e[0;90m"
    git push --set-upstream origin $NEW_BRANCH_NAME
    printf "\e[1;96mHere's the list of your branches:\n\e[0;90m"
    git branch | less -F -X
    if [[ $PUSH ]]; then
      BRANCH=$NEW_BRANCH_NAME
      stage_commit_push
    fi
  fi
}

fresh_options() {
  if [[ $NEW_BRANCH_NAME ]]; then
    new_branch
  else
    usage_guide
    exit 1
  fi
  exit 0
}
