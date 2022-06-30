#!/bin/bash
## Set environment
export DEBIAN_FRONTEND=noninteractive

## Update Ubuntu
apt-get update
apt-get --with-new-pkgs upgrade -y
apt-get autoremove -y
apt-get autoclean -y

## Install YARA
apt-get install -y build-essential automake libtool pkg-config libjansson-dev libmagic-dev libssl-dev
wget --no-verbose --show-progress --progress=bar:force -P /tmp https://github.com/VirusTotal/yara/archive/refs/tags/v4.2.2.tar.gz 2>&1
tar -zxvf /tmp/v4.2.2.tar.gz -C /tmp
cd /tmp/yara-4.2.2/
./bootstrap.sh
./configure --enable-cuckoo --enable-magic --enable-macho --enable-dex --with-crypto
make
make check
make install
ldconfig -v

## Install Volatility
apt-get install -y python3-dev python3-venv jq
sudo -i -u vagrant bash << EOF
python3 -m venv /home/vagrant/venv
source /home/vagrant/venv/bin/activate
pip list -o --format json | jq -r '.[].name' | xargs -n 1 pip install -U
pip install wheel
pip install pefile yara-python capstone pycryptodome volatility3
EOF

## Reboot
reboot
