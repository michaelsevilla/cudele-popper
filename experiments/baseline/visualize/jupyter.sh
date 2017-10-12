#!/bin/bash

set -e -x
docker run --rm -v `dirname $PWD`:/home/jovyan/work -p 81:8888 jupyter/scipy-notebook:c411f52fcc93
