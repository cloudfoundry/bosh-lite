#!/bin/bash

set -ex

echo "Removing kernels that do not match $(uname -r)"

# delete stale linux kernels
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*' | grep -v `uname -r` | xargs apt-get -y purge

# delete stale linux headers
dpkg --list | awk '{ print $2 }' | grep 'linux-headers-3.*' | grep -v `uname -r` | xargs apt-get -y purge

# delete linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
