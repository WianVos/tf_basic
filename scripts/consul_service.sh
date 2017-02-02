#!/usr/bin/env bash
set -e

echo "Starting Consul..."

echo "using systemctl"
sudo systemctl enable consul.service
sudo systemctl start consul
