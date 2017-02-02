#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get install -y unzip
else
  sudo yum update -y
  sudo yum install -y unzip wget
fi


echo "Fetching Consul..."
CONSUL=0.7.2
cd /tmp
curl https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -o consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -p /opt/consul/data


CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')

# Write the flags to a temporary file
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-join=${CONSUL_JOIN} -data-dir=/etc/consul.d "
EOF


echo "Installing Systemd service..."
sudo mkdir -p /etc/systemd/system/consul.d
sudo chown root:root /tmp/consul.service
sudo mv /tmp/consul.service /etc/systemd/system/consul.service
sudo chmod 0644 /etc/systemd/system/consul.service
sudo mv /tmp/consul_flags /etc/default/consul
sudo chown root:root /etc/default/consul
sudo chmod 0644 /etc/default/consul
