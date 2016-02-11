#!/bin/bash

set -e

DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install iptables-persistent
iptables -I FORWARD 1 -p all -o eth0 -d 10.244.0.0/16 -j DROP
iptables-save > /etc/iptables/rules.v4
