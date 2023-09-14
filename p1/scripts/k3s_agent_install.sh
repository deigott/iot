#!/bin/bash

# Setup path of the controller node token.
K3S_TOKEN_FILE="/vagrant/.configs/master-token"

# Install k3s and configure a worker node.
curl -sfL https://get.k3s.io | K3S_TOKEN_FILE=${K3S_TOKEN_FILE} K3S_URL="https://192.168.56.110:6443" INSTALL_K3S_EXEC="--flannel-iface=eth1" sh - && echo "(+) Worker is configured."

# Remove controller node token after configuring worker node.
sudo rm -rf /vagrant/.configs && echo "(+) Token Removed."