#!/bin/bash

###########################################################################
# A usage guide for the Giti.
# -------------------------------------------------------------------------
# Author: Mohsen Karami
# Email: karami.mohsen@protonmail.com
###########################################################################


usage_guide() {
  cat << EOF >&2
Giti 0.3.2, a Git utility.
Usage: giti <command> [<options>] [<args>]


Common Giti commands are listed below:

  push    Stage, commit, and push the working tree files into the remote repository
  setup   Configure your git identity (name and email) locally or globally


Common Giti options are listed below:

  -h    --help                                 Print the help document
  
  [push]
  -i    --initial                              Push the current branch and set the remote as upstream
  -r    --revise <integer>                     Override the specified number of pushed commits with a fresh one
  -m    --merge <integer>                      Merge the working tree changes with the specified number of pushed commits and override them with a fresh commit.
  -t    --tag <tag-name>                       Attach the user input as a tag to the latest commit and push it to the remote server.
        --hash <commit-hash>                   Perform the previous action on a specific commit: It should get used alongside the -t option.
  
  [setup]
        --clear                                Clear your git identity (name and email) locally or globally.


Giti is available under GPLv3 at https://github.com/mohsen-karami/giti
EOF
  exit 1
}
