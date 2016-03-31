#!/bin/bash

set -e

# Add tty chack around `mesg n` so provisioners don't report `stdin: not a tty`
sed -i -e 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
