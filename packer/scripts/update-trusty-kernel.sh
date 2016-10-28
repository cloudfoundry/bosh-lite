#!/bin/bash

set -ex

export UCF_FORCE_CONFFNEW=YES
export DEBIAN_FRONTEND=noninteractive

apt-get -y --force-yes install linux-generic-lts-xenial

reboot
sleep 60
