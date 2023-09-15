#!/bin/bash

# Installing Network tools (ifconfig)
sudo apt install net-tools -y

# Install K3s server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address=192.168.56.110 --write-kubeconfig-mode 644 --flannel-iface=eth1" sh - && echo "[INFO]  Master is configured."

# Add kubectl alias for all users
echo "[INFO]  Add kubectl alias for all users"
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh