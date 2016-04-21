#!/bin/bash

set -ex

DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install iptables-persistent

# allows network to recognize all traffic coming from same network, so that source can be correctly identified
iptables -I POSTROUTING -t nat --source 10.244.0.0/16 --destination 10.244.0.0/16 --jump ACCEPT
iptables-save > /etc/iptables/rules.v4
