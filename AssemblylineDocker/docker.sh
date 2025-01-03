#!/bin/bash
echo 'Provisioner: docker.sh'

## Set Environment
export DEBIAN_FRONTEND=noninteractive

## Install Docker
url='https://download.docker.com/linux/ubuntu/gpg'
ring='/etc/apt/keyrings/docker.gpg'
list='/etc/apt/sources.list.d/docker.list'
repo='https://download.docker.com/linux/ubuntu'
curl -fsSL $url | gpg --dearmor -o $ring
echo "deb [arch=$(dpkg --print-architecture) signed-by=$ring] $repo $(lsb_release -cs) stable" | tee $list
apt-get -o DPkg::Lock::Timeout=-1 update
apt-get -o DPkg::Lock::Timeout=-1 install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
ln -vs /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
