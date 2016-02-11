#!/usr/bin/env bash

set -e

# Copied from bosh/stemcell_builder/stages/rsyslog/apply.sh
# (Not installing custom rsyslog version, for now...)

# Configure /var/log directory
filenames=( auth.log daemon.log debug kern.log lpr.log mail.err mail.info \
              mail.log mail.warn messages syslog user.log )

echo "Initializing syslog dirs"
for filename in ${filenames[@]}; do
  fullpath=/var/log/$filename
  echo "Initializing: $fullpath"
  touch ${fullpath} && chown syslog:adm ${fullpath} && chmod 640 ${fullpath}
done
