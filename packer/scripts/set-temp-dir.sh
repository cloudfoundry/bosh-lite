#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

(cat <<PROFILE
export TMPDIR=${HOME}/tmp
PROFILE
) >> $HOME/.profile

mkdir -p $HOME/tmp

[[ `id ubuntu` ]] && user=ubuntu || user=vagrant
chown -R $user:$user $HOME/tmp
