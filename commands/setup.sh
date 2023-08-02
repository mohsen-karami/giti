#!/bin/bash

set_up() {
  if [[ $CLEAR ]]; then
    printf "\n\e[1mYou're going to \e[1;31mCLEAR\e[0;1m your Git name and email.\n\n"
  else
    printf "\n\e[1mYou're going to configure your Git name and email.\n\n"
  fi
  printf "\e[1;93mSelect the scope in which you would like to configure Git's identity.\n\e[1;0m"
  scope_options=("Global - All Repositories" "Local - This Repository")
  select_option "${scope_options[@]}"
  selected_scope=$?
  scopes=("--global" "--local")
  scope=${scopes[$selected_scope]}
  if [[ $CLEAR ]]; then
    git config $scope --unset user.name
    git config $scope --unset user.email
    exit 0
  else
    printf "\e[1;96mEnter your name\n\e[0;90m"
    read -e name
    while [ -z ${name} ]; do
      printf "\e[1;93mName is required.\n\e[1;0m"
      read -e name
    done
    printf "\e[1;96mEnter your email\n\e[0;90m"
    read -e email
    while [ -z ${email} ]; do
      printf "\e[1;93mEmail is required.\n\e[1;0m"
      read -e email
    done
    git config $scope user.email $email
    git config $scope user.name $name
  fi
}
