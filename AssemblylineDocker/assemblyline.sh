#!/bin/bash
echo 'Provisioner: assemblyline.sh'

## Install Assemblyline
echo '{"default-address-pools":[{"base":"10.201.0.0/16","size":24}]}' | jq '.' | tee /etc/docker/daemon.json
systemctl restart docker
systemctl status docker
out=$(git clone https://github.com/CybercentreCanada/assemblyline-docker-compose.git /root/git/assemblyline-docker-compose 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
mkdir -v /root/deployments
# cp -Rv /root/git/assemblyline-docker-compose/full_appliance /root/deployments/assemblyline
cp -Rv /root/git/assemblyline-docker-compose/minimal_appliance /root/deployments/assemblyline
# sed -i 's/log_level: WARNING/log_level: DEBUG/' /root/deployments/assemblyline/config/config.yml
sed -i '/core:/,/^  redis:/s/min_instances: 0/min_instances: 1/' /root/deployments/assemblyline/config/config.yml
cp -v /vagrant/scaler_server.py /root/deployments/assemblyline/scaler_server.py
sed -i '/scaler:/,/volumes:/ {
  /volumes:/a \      - /root/deployments/assemblyline/scaler_server.py:/var/lib/assemblyline/.local/lib/python3.11/site-packages/assemblyline_core/scaler/scaler_server.py:ro
}' /root/deployments/assemblyline/docker-compose.yaml
key='/root/deployments/assemblyline/config/nginx.key'
cert='/root/deployments/assemblyline/config/nginx.crt'
out=$(openssl req -x509 -sha256 -newkey rsa:4096 -keyout $key -out $cert -days 365 -nodes -subj '/CN=localhost' 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo 'TLS certificate generated:'
    ls -l $key
    ls -l $cert
fi
cd /root/deployments/assemblyline && pwd
out=$(docker-compose pull --quiet --ignore-buildable 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
out=$(docker-compose build 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
out=$(docker-compose -f bootstrap-compose.yaml pull --quiet 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
out=$(docker-compose up -d --wait --scale archiver=0 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
out=$(docker-compose -f bootstrap-compose.yaml up -d 2>&1)
if [ $? -ne 0 ]; then
    echo "$out" > /dev/stderr
else
    echo "$out"
fi
