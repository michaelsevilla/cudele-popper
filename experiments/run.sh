#!/bin/bash
set -ex

cd baseline-durability
./run.sh
cd -

cd cudele-mechanisms
./run.sh
cd -
