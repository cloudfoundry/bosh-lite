# Set up sudo - base careful to set the file attribute before copying to
# sudoers.d
( cat <<'EOP'
%packer ALL=NOPASSWD:ALL
EOP
) > /tmp/packer
chmod 0440 /tmp/packer
mv /tmp/packer /etc/sudoers.d/

apt-get -y update
#apt-get -y upgrade
#apt-get -y install curl
apt-get clean

( cat  <<'EOP'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";
EOP
) >  /etc/apt/apt.conf.d/20auto-upgrades
