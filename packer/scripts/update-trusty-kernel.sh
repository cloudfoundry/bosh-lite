#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

export UCF_FORCE_CONFFNEW=YES
export DEBIAN_FRONTEND=noninteractive

apt-get -y --force-yes install linux-generic-lts-vivid

reboot
sleep 60
