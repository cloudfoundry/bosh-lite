#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

echo '*/15 * * * * root ntpdate ntp.ubuntu.com' >> /etc/crontab
