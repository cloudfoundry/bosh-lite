#!/bin/bash

set -ex

# Get build essentials
apt-get install -y build-essential make perl

KERNEL_RELEASE=$(uname -r)

# Install kernel headers if they're missing
dpkg --status linux-headers-$KERNEL_RELEASE 2>&1 >/dev/null
if [ $? -ne 0 ]; then
    apt-get install -y linux-headers-$KERNEL_RELEASE
    installed_headers=1
fi

# Install the tools
if [ -f linux.iso ]; then
    echo "Installing VMware Tools"
    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

    /tmp/vmware-tools-distrib/vmware-install.pl -d
    rm /home/vagrant/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
fi

# Remove the headers if we installed them
if [ -n "$installed_headers" ]; then
    apt-get -y remove linux-headers-$KERNEL_RELEASE
fi
