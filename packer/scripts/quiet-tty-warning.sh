#!/bin/bash

set -e

# Add tty chack around `mesg n` so provisioners don't report `stdin: not a tty`
cp /root/.profile /root/.profile.orig
cat /root/.profile.orig | sed -e 's/^mesg n/tty -s \&\& mesg n/g' > /root/.profile
rm /root/.profile.orig
