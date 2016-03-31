#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

# Use us.archive.ubuntu.com instead of EC2 mirrors, which are broken
sed -i -e 's/http.*\.archive\.ubuntu\.com/http:\/\/us.archive.ubuntu.com/' /etc/apt/sources.list

rm -rf /etc/apt/sources.list.d/multiverse-trusty*

apt-get -y update
apt-get -y clean
