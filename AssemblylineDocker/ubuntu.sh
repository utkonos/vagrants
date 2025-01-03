#!/bin/bash
echo 'Provisioner: ubuntu.sh'

## Set Environment
export DEBIAN_FRONTEND=noninteractive

## Update Ubuntu
printf 'APT::Get::Always-Include-Phased-Updates true;\nUpdate-Manager::Always-Include-Phased-Updates true;' | sudo tee /etc/apt/apt.conf.d/99-Phased-Updates
apt-get -o DPkg::Lock::Timeout=-1 update
apt-get -o DPkg::Lock::Timeout=-1 --with-new-pkgs upgrade -y
apt-get -o DPkg::Lock::Timeout=-1 autoremove -y
apt-get -o DPkg::Lock::Timeout=-1 autoclean -y
