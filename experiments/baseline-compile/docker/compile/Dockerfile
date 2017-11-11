FROM ubuntu:trusty

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y wget xz-utils make gcc bc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* debian/
