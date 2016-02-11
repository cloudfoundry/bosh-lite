#!/bin/bash

set -e

export UCF_FORCE_CONFFNEW=YES
export DEBIAN_FRONTEND=noninteractive

apt-get -y --force-yes install linux-generic-lts-vivid

reboot
sleep 60
