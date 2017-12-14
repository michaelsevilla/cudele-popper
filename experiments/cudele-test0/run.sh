#!/bin/bash

set -ex

# setup the docker command
ROOT=`dirname $PWD | xargs dirname`
RUN="docker run -it --rm --net host -v $HOME/.ssh:/root/.ssh -w /root -v $ROOT/ansible/srl:/popper/ansible/roles/srl/"
ANSIBLE="michaelsevilla/ansible --forks 50 --skip-tags package-install,with_pkg"
CEPH_ANSIBLE="$RUN -v $ROOT/ansible/ceph:/root $ANSIBLE"
SRL_ANSIBLE="$RUN -v `pwd`/site:/root $ANSIBLE"

#for site in "nojournal-cache" "journal120-cache" "journal150-cache" "journal180-cache" "journal30-cache" "journal60-cache" "journal90-cache"; do
for site in "nojournal-cache"; do
  #nclients=3

  # configure ceph and setup results directory
  mkdir -p results/$site/logs || true
  cp site/* $ROOT/ansible/ceph || true
  cp site_confs/${site}.yml site/group_vars/all
  cp -r site/group_vars $ROOT/ansible/ceph/
  #cp inventory/${nclients}client site/hosts
  #cp inventory/${nclients}client $ROOT/ansible/ceph//hosts
  cp site/hosts $ROOT/ansible/ceph/hosts

  # cleanup and start ceph
  $SRL_ANSIBLE cleanup.yml
  $CEPH_ANSIBLE ceph.yml cephfs.yml
  $SRL_ANSIBLE ceph_pgs.yml ceph_monitor.yml ceph_wait.yml
  
  # warmup and get baseline
  for i in `seq 0 2`; do
    ./ansible-playbook.sh -e site=$site -e nfiles=100000 ../workloads/creates.yml
  done
  
  ./ansible-playbook.sh -e site=$site collect.yml
done
