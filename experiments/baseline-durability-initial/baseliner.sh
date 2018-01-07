#!/bin/bash

# cleanup
cd results; ls | grep -v visualize.ipynb | xargs rm; cd -
set -ex

# setup the docker command
RUN="docker run -it --rm --net host -v $HOME/.ssh:/root/.ssh -w /root/site"
ANSIBLE="michaelsevilla/ansible --forks 50 --skip-tags package-install,with_pkg"

# run the baseliner
$RUN -v `pwd`:/root $ANSIBLE \
  ../workloads/radosbench.yml \
  ../workloads/netbench.yml \
  ../workloads/osdbench.yml


