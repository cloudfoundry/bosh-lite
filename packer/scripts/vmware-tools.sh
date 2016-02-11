#!/bin/bash

set -ex

apt-get install -y linux-headers-$(uname -r) build-essential make perl dkms git

mount -o loop /home/vagrant/linux.iso /media/cdrom

cd /tmp

git clone https://github.com/rasa/vmware-tools-patches.git
cd vmware-tools-patches
cp /media/cdrom/VMwareTools-*.tar.gz .

./untar-and-patch-and-compile.sh

rm /home/vagrant/linux.iso
umount /media/cdrom

apt-get remove -y linux-headers-$(uname -r)
