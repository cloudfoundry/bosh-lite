#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

apt-get -y install linux-headers-$(uname -r) build-essential make perl dkms

mount -o loop /home/vagrant/VBoxGuestAdditions.iso /media/cdrom
# Ignore X driver failure, we don't need it
/media/cdrom/VBoxLinuxAdditions.run || true
umount /media/cdrom
