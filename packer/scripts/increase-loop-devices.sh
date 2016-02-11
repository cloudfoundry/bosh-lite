#!/bin/bash

sed -i.bak 's/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 loop.max_loop=255\"/' /etc/default/grub
update-grub
