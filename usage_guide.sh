#!/bin/bash

###########################################################################
# A usage guide for the Giti.
# -------------------------------------------------------------------------
# Author: Mohsen Karami
# Email: karami.mohsen@protonmail.com
###########################################################################


usage_guide() {
  cat << EOF >&2
Giti 0.2.2, a Git utility.
Usage: giti <command> [<options>] [<args>]


Common Giti commands are listed below:

  push    Stage, commit, and push the working tree files into the remote repository


Common Giti options are listed below:

  -h    --help                                 Print the help document
  -r    --revise <integer>                     Override the specified number of commits with a fresh one
                                               (This option is merely available through the 'push' command)


Giti is available under GPLv3 at https://github.com/mohsen-karami/giti
EOF
  exit 1
}
