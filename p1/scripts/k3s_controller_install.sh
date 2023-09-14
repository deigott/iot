#!/bin/bash

# Setup path of the controller node token.
NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"


# Configuring shared folder
sudo mkdir /vagrant/.configs
      
curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode 644 --flannel-iface=eth1 && echo "[INFO] Master is configured."

cp ${NODE_TOKEN} /vagrant/.configs/master-token && echo "[INFO] Token is shared."

# Setup alias for kubectl to k
echo "[SETUP] : initiat aliases for all machine users "
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

sudo yum install net-tools -y