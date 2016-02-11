#!/bin/bash

set -e

(cat <<PROFILE
export TMPDIR=${HOME}/tmp
PROFILE
) >> $HOME/.profile

mkdir -p $HOME/tmp

[[ `id ubuntu` ]] && user=ubuntu || user=vagrant
chown -R $user:$user $HOME/tmp
