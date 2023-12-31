#!/bin/bash

# Setup path of the controller node token.
K3S_TOKEN_FILE="/vagrant/.configs/master-token"
K3S_CONFIG_FILE="/vagrant/.configs/k3s.yml"

# Install k3s and configure a worker node.
curl -sfL https://get.k3s.io | K3S_TOKEN_FILE=${K3S_TOKEN_FILE} K3S_URL="https://192.168.56.110:6443" INSTALL_K3S_EXEC="--flannel-iface=eth1" sh - && echo "[INFO] Worker is configured."

# Remove controller node token after configuring worker node.
sudo rm -rf /vagrant/.configs/master-token && echo "[INFO] Token Removed."

# Setup alias for kubectl to k
echo "[SETUP] : initiat aliases for all machine users "
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

# Link agent to controller api
echo "export KUBECONFIG=$K3S_CONFIG_FILE" >> /etc/profile

sudo yum install net-tools -y