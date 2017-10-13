#!/bin/bash
# Put all your cleanup tasks here.
set -ex

ARGS="--forks 50 --skip-tags package-install,with_pkg"
VARS="-e @/popper/vars.yml -e @/popper/ansible/vars.yml -i /etc/ansible/hosts"
ROOT=`dirname $PWD | xargs dirname`
docker run -it --rm \
  --net host \
  -v $HOME/.ssh:/root/.ssh \
  -v `pwd`/ansible/group_vars:/root/group_vars \
  -v `pwd`/hosts:/etc/ansible/hosts \
  -v `pwd`/ansible/ansible.cfg:/etc/ansible/ansible.cfg \
  -v `pwd`/ansible/ceph.yml:/root/ceph.yml \
  -v `pwd`:/popper \
  -v $ROOT/ansible/ceph:/root -w /root \
  -v $ROOT/ansible/srl:/popper/ansible/roles/srl \
  -e ANSIBLE_CONFIG="/etc/ansible/ansible.cfg" \
  michaelsevilla/ansible $ARGS $VARS /popper/ansible/cleanup.yml
  #--entrypoint=/bin/bash michaelsevilla/ansible -c "$@"
 
exit 0
