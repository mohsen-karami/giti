#!/bin/bash

###########################################################################
# A usage guide for the Giti.
# -------------------------------------------------------------------------
# Author: Mohsen Karami
# Email: karami.mohsen@protonmail.com
###########################################################################


usage_guide() {
  cat << EOF >&2
Giti 0.2, a Git utility.
Usage: giti <command>

Common Giti commands are listed below:

Note: In all commands below, the commit message and description get formatted.

  push    Stage, commit, and push the working tree files into the remote repository

Giti is available under GPLv3 at https://github.com/mohsen-karami/giti
EOF
  exit 1
}
