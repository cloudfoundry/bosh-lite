#!/bin/bash

set -ex

mkdir -m 700 -p ~/.ssh

wget -qO- https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
