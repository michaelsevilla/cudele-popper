#!/bin/bash
set -x

./ansible.sh mdss -m shell -a "docker exec ceph-\`hostname\`-mds ceph --admin-daemon /var/run/ceph/ceph-mds.\`hostname\`.asok $@"

