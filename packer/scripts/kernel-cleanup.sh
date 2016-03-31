#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

export DEBIAN_FRONTEND=noninteractive

echo "Removing kernels that do not match $(uname -r)"

# delete stale linux kernels
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*' | grep -vF "$(uname -r)" | xargs apt-get -y purge

# delete stale linux headers
dpkg --list | awk '{ print $2 }' | grep 'linux-headers-3.*' | grep -vF "$(uname -r)" | xargs apt-get -y purge

# delete linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

# miscellaneous packages
apt-get -y purge linux-firmware
