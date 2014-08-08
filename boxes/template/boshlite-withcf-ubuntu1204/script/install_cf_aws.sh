# create cf release
set -e
set -x

function stop_service {
  rm /etc/service/*
  service nginx stop
  sleep 10
}

function start_service {
  service="bosh-monitor
    director
    nats
    warden
    worker-0
    worker-1"
  for s in $service; do
	ln -s /etc/sv/$s /etc/service/$s
  done
  service nginx start
  sleep 10
}

function set_env {
  service="bosh-monitor
    director
    worker-0
    worker-1"
  for s in $service; do
    echo '/mnt' > /etc/sv/$s/env/TMPDIR
  done
}


PATH=/opt/rbenv/shims:/opt/rbenv/bin:$PATH
export TMPDIR=/mnt

ifconfig lo:1 192.168.50.4 netmask 255.255.255.0

stop_service
cp -a /opt/bosh /mnt/bosh
cp -a /opt/warden /mnt/warden
mount --bind /mnt/bosh /opt/bosh
mount --bind /mnt/warden /opt/warden
set_env
start_service

mv /tmp/bosh-lite /mnt
cd /mnt/bosh-lite/

wget -nv --tries=10 http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz -O latest-bosh-stemcell-warden.tgz
bosh -n target 127.0.0.1
bosh -u admin -p admin -n upload stemcell latest-bosh-stemcell-warden.tgz

(
  cd cf-release
  git checkout deployed-to-prod
  last=` tail -1 releases/index.yml |grep -Po "\d+"`
  ref=${CF_VERSION:-"$last"}
  git checkout v${ref}
  cmd="bosh -u admin -p admin -n upload release releases/cf-${ref}.yml"
  $cmd || (sleep 120; bosh -u admin -p admin releases | grep cf ) || $cmd
)

apt-get -y install unzip

wget  -r --tries=10 https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0/spiff_linux_amd64.zip -O /usr/local/bin/spiff.zip
unzip /usr/local/bin/spiff.zip -d /usr/local/bin/
chmod +x /usr/local/bin/spiff

CF_RELEASE_DIR=cf-release ./scripts/make_manifest_spiff

cmd="bosh -u admin -p admin -n deploy"
$cmd || $cmd

sleep 30
# wipe out all containers before exporting box. They will be lost anyway
/opt/warden/warden/root/linux/clear.sh /opt/warden/containers/
mount | grep /opt/warden/disks | cut -f1 -d' ' |sort -r | xargs umount || true
sleep 1
mount | grep /opt/warden/disks | cut -f1 -d' ' |sort -r | xargs umount || true
rm -rf /opt/warden/disks/ephemeral_mount_point/*


#copy over data from local disk to rootfs
stop_service
lsof |grep /opt || true
umount /opt/bosh || (sleep 10; umount /opt/bosh)
umount /opt/warden || (sleep 10; umount /opt/warden) || (sleep 10; umount -f -l /opt/warden)
cp -a -f /mnt/bosh /opt
cp -a -f /mnt/warden /opt
start_service

chown ubuntu:ubuntu /home/ubuntu/.bosh_config
