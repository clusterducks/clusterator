#!/bin/bash

# this thing doesn't really work, some issue w/ key signing
## sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
## echo 'deb https://apt.dockerproject.org/repo ubuntu-vivid main' > /etc/apt/sources.list.d/docker.list

# get and install docker-engine
curl -O https://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_1.9.1-0~vivid_amd64.deb
dpkg -i docker-engine_*.deb

# get and install docker-machine
curl -L https://github.com/docker/machine/releases/download/v0.5.6/docker-machine_linux-amd64 > docker-machine
cp docker-machine > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine

# update package list, install git, restart docker, install docker-compose
apt-get update
apt-get -y install git python-pip
/etc/init.d/docker restart
pip install docker-compose

# clone our clusterator
git clone https://github.com/n8behavior/clusterator.git

# before continuing install some dependencies
apt-get -y install linux-image-extra-`uname -r`
apt-get -y install autoconf autotools-dev build-essential debhelper autotools-dev vlan avahi-utils dnsmasq

# get into clusterator directory, build and install it
cd clusterator
./bin/build
cd ..
dpkg -i clusterator_*.deb

echo " DONE - you may start clusterator with: sudo cluster-start "

