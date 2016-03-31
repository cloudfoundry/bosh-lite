#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

# Add tty chack around `mesg n` so provisioners don't report `stdin: not a tty`
sed -i -e 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile
