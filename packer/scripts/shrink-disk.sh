#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Print commands and their arguments as they are executed.

# Zero out the free space to save space in the final image
# Ignore no space left on device error
dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY
