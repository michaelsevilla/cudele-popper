#!/bin/bash

if [ -z $1 ]; then
  echo "Uh oh. Usage: $0 <number of files to create>"
  exit 1
fi

# cleanup
set -ex

# setup the docker command
RUN="docker run -it --rm --net host -v $HOME/.ssh:/root/.ssh -w /root/site"
ANSIBLE="michaelsevilla/ansible --extra-vars "nfiles=$1" --forks 50 --skip-tags package-install,with_pkg"

# run the benchmark
$RUN -v `pwd`:/root $ANSIBLE ../workloads/metawrites.yml
