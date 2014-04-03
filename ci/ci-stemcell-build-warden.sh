#!/bin/bash -l
set -e
. ~/.bashrc
PATH=/var/lib/jenkins/.rbenv/shims:/var/lib/jenkins/.rbenv/bin:$PATH
export STEMCELL_BUILD_NUMBER=${BUILD_NUMBER}

echo $STEMCELL_BUILD_NUMBER

bundle install

./spec/ci_build.sh ci:build_local_stemcell[warden,ubuntu,ruby]

mkdir output || true
cp /mnt/stemcells/warden/boshlite/ubuntu/work/work/*.tgz ./output/
