#!/bin/bash

set -x

useradd vagrant 
echo "vagrant:vagrant" | chpasswd
