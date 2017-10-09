#!/bin/bash

set -ex

# horrible hack
HASH=`cat vars.yml | grep "ceph_docker_version: " | grep -v "#" | awk '{print $2}'`
GITR=`cat vars.yml | grep "ceph_repository: " | grep -v "#" | awk '{print $2}'`
USERNAME=`cat vars.yml | grep "ceph_docker_username: " | grep -v "#" | awk '{print $2}'`
IMAGENAME=`cat vars.yml | grep "ceph_docker_imagename: " | grep -v "#" | awk '{print $2}'`
if [ -z $HASH ]; then exit 1; fi
if [ -z $GITR ]; then exit 1; fi
if [ -z $USERNAME ]; then exit 1; fi
if [ -z $IMAGENAME ]; then exit 1; fi
TAG="$USERNAME/$IMAGENAME:$HASH"
echo "building Docker image with Ceph version $HASH from git repo $GITR tagged with $TAG"

# create the image
SRC="/tmp/ceph-daemon"
mkdir $SRC || true
cd $SRC

# pull base image from ceph (we will layer on top of this)
wget https://raw.githubusercontent.com/systemslab/docker-cephdev/master/aliases.sh
. aliases.sh && rm aliases.sh
docker pull ceph/daemon:tag-build-master-jewel-ubuntu-14.04
docker tag ceph/daemon:tag-build-master-jewel-ubuntu-14.04 ceph/daemon:jewel
docker pull cephbuilder/ceph:latest

dmake \
  -e SHA1_OR_REF="$HASH" \
  -e GIT_URL="$GITR" \
  -e BUILD_THREADS=`grep processor /proc/cpuinfo | wc -l` \
  -e CONFIGURE_FLAGS="-DWITH_TESTS=OFF" \
  -e RECONFIGURE="true" \
  cephbuilder/ceph:latest build-cmake
cd -

docker tag ceph-$HASH ceph/daemon:$HASH

docker run \
  --name copier \
  --entrypoint=/bin/bash \
  -v $SRC:/ceph \
  ceph/daemon:jewel -c "cp -r /ceph/build/install/usr/* /usr"
docker commit --change='ENTRYPOINT ["/entrypoint.sh"]' copier $USERNAME/$IMAGENAME:$HASH &> /dev/null
docker stop copier
docker rm copier

set +x
echo "Great SUCCESS!!!! Image name is: $USERNAME/$IMAGENAME:$HASH"
