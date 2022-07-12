#!/bin/bash
## Set environment
export DEBIAN_FRONTEND=noninteractive

## Update Ubuntu
apt-get update
apt-get --with-new-pkgs upgrade -y
apt-get autoremove -y
apt-get autoclean -y

## Reboot
reboot
