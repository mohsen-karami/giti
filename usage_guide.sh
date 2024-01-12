#!/bin/bash

###########################################################################
# A usage guide for the Giti.
# -------------------------------------------------------------------------
# Author: Mohsen Karami
# Email: karami.mohsen@protonmail.com
###########################################################################


usage_guide() {
  cat << EOF >&2
Giti 0.4.0, a Git utility.
Usage: giti <command> [<options>] [<args>]


Common Giti commands are listed below:

  push    Stage, commit, and push the working tree files into the remote repository
  setup   Configure your git identity (name and email) locally or globally


Common Giti options are listed below:

  -h    --help                                 Print the help document
  
  [fresh]

  -b    --branch <branch-name>                 Create a new branch that originates from the specified branch.

  -n    --name <branch-name>                   Create a new branch with the given name.

        --push                                 Push the working tree changes to the newly created repository.

  [push]

        --temp                                 Push the changes as a temporary commit with a default message and description.

        --staged                               Solely push the staged changes

  -a    --append                               Add the recent changes to the last commit.

  -i    --initial                              Push the current branch and set the remote as upstream

  -m    --merge <integer>                      Merge the working tree changes with the specified number of pushed commits and override them with a fresh commit.
  -r    --revise <integer>                     Override the specified number of pushed commits with a fresh one
        --manual                               Enable the user to modify the fetched commits before pushing them.
  
  -t    --tag <tag-name>                       Attach the user input as a tag to the latest commit and push it to the remote server.
        --hash <commit-hash>                   Perform the previous action on a specific commit.
  
  [remove]

  -b    --branch <branch-name>                 Remove the specified branch from your local machine and the remote repository.

  -cb   --current-branch                       Remove the current branch from your local machine and the remote repository.
  
  [setup]

        --clear                                Clear the git identity (name and email) locally or globally.


Giti is available under GPLv3 at https://github.com/mohsen-karami/giti
EOF
  exit 1
}
