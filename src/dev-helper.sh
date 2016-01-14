#!/bin/bash

# sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# echo 'deb https://apt.dockerproject.org/repo ubuntu-vivid main' > /etc/apt/sources.list.d/docker.list

curl -O https://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_1.9.1-0~vivid_amd64.deb
sudo dpkg -i docker-engine_*.deb
sudo apt-get update
sudo apt-get -y install linux-image-extra-`uname -r`
sudo apt-get -y install autoconf autotools-dev build-essential debhelper autotools-dev python-pip vlan avahi-utils dnsmasq git
sudo /etc/init.d/docker restart
sudo pip install docker-compose
git clone https://github.com/n8behavior/clusterator.git
cd clusterator
./bin/build
cd ..
sudo dpkg -i clusterator_*.deb

