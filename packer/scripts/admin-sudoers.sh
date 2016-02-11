#!/bin/bash

set -ex

# Users should be added to admin group in packer template
groupadd -r admin -f

cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g'      /etc/sudoers
