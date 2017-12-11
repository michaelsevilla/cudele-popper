#!/bin/bash

set -e -x

docker run --rm -p 81:8888 \
  -v $PWD:/home/jovyan/work \
  jupyter/scipy-notebook:c411f52fcc93
