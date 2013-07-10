set -x
apt-get update
apt-get -y install ruby1.9.1-full ruby1.9.1-dev libopenssl-ruby1.9.1 rdoc1.9.1 ri1.9.1 irb1.9.1 build-essential wget ssl-cert curl
apt-get -y install rubygems1.9.1
grep -q gems/1.9.1 /etc/profile || echo 'export PATH=$PATH:/var/lib/gems/1.9.1/bin' >> /etc/profile

# Redis 2.x installed for lucid
wget -c http://mirror.pnl.gov/ubuntu//pool/universe/r/redis/redis-server_2.2.12-1build1_amd64.deb -O /tmp/redis-2.2.12.deb
dpkg -i /tmp/redis-2.2.12.deb

which chef-solo || gem install chef --no-ri --no-rdoc -v 10.26.0
grep -q vagrant /etc/passwd || useradd vagrant
