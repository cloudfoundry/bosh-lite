#!/bin/bash

set -ex

apt-get -y install ruby2.0 ruby2.0-dev

# Rename original so updates don't undo the change
dpkg-divert --add --rename --divert /usr/bin/ruby.divert /usr/bin/ruby
dpkg-divert --add --rename --divert /usr/bin/gem.divert /usr/bin/gem

# Create an alternatives entry pointing ruby -> ruby2.0
update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1
update-alternatives --install /usr/bin/gem gem /usr/bin/gem2.0 1
