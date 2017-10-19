#!/bin/bash

set -ex

for i in $CLOUDLAB_NODES; do
  echo "---- " $i
  scp ~/.ssh/id_rsa.pub ${USER}@$i:~/.ssh/id_rsa.pub
  scp ~/.ssh/id_rsa ${USER}@$i:~/.ssh/id_rsa
  ssh ${USER}@$i "sudo usermod -aG docker ${USER}"
done

set +x
echo "DONE!"
