#!/bin/bash

set -ex

echo 'nameserver 8.8.8.8' >> /etc/resolvconf/resolv.conf.d/head
resolvconf -u
