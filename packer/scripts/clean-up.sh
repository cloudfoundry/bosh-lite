#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

# Remove release upgrader to prevent check-new-release from running
apt-get -y remove ubuntu-release-upgrader-core

# Make sure Udev doesn't block our network (http://6.ptmc.org/?p=164)
echo "Cleaning up udev rules"
rm -rf /etc/udev/rules.d/70-persistent-net.rules
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/

echo "Cleaning up BOSH provisioner left-overs"
rm -rf /opt/bosh-provisioner/{repos,blobstore,tmp,assets}
rm -rf /var/vcap/data/compile
rm -rf /var/vcap/data/tmp/*blobstore*

echo "Cleaning up /tmp"
rm -rf /tmp/*

echo "Cleaning up /home/vagrant"
rm -rf /home/vagrant/*

if [ -d "/var/lib/dhcp" ]; then
	echo "Removing DHCP leases"
	rm /var/lib/dhcp/*
fi

echo "Cleaning up apt packages"
apt-get -y autoremove --purge
apt-get -y clean

echo "Cleaning up apt repository cache"
find /var/lib/apt/lists -type f | xargs rm -f

echo "Cleaning up dpkg backup files"
find /var/cache/debconf -type f -name '*-old' | xargs rm -f

echo "Cleaning up /var/log"
find /var/log -type f -user root | xargs rm -rf
for file in $(find /var/log -type f -user syslog); do
  echo > $file
done

echo "Cleaning up bosh logs"
find /var/vcap/bosh/log /var/vcap/sys/log -type f | xargs rm -rf

echo "Cleaning up locales"
find /usr/share/locale -maxdepth 1 -mindepth 1 -not -name 'en*' | xargs rm -rf

echo "Cleaning up /usr/share/doc"
rm -rf /usr/share/doc/*
