#!/usr/bin/env bash

set -e

echo '*/15 * * * * root ntpdate ntp.ubuntu.com' >> /etc/crontab
