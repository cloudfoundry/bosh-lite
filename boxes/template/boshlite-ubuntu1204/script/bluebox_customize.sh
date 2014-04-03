# Set up sudo - base careful to set the file attribute before copying to
# sudoers.d

apt-get -y update
#apt-get -y upgrade
#apt-get -y install curl
apt-get -y install make
apt-get -y install postgresql-client-common
apt-get -y install libpq-dev
apt-get clean
