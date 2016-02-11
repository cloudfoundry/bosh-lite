#!/bin/bash

set -e

gem install bosh_cli --no-ri --no-rdoc

(cat <<BOSH_CONFIG
auth:
  https://127.0.0.1:25555:
    username: admin
    password: admin
BOSH_CONFIG
) > $HOME/.bosh_config

bosh target 127.0.0.1

[[ `id ubuntu` ]] && user=ubuntu || user=vagrant
chown $user:$user $HOME/.bosh_config

wget "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" -O /tmp/cf-cli.tgz
tar xf /tmp/cf-cli.tgz -C /tmp
mv /tmp/cf /usr/local/bin/
