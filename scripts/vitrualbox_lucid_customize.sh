set -x

# Kernel backporting for Warden
apt-get install -y linux-image-generic-lts-backport-natty

# Redis 2.x installed for lucid
wget -c http://mirror.pnl.gov/ubuntu//pool/universe/r/redis/redis-server_2.2.12-1build1_amd64.deb -O /tmp/redis-2.2.12.deb
dpkg -i /tmp/redis-2.2.12.deb

gem uninstall chef
gem install chef --no-ri --no-rdoc -v 10.26.0
