#!/bin/bash

# Setup path of the controller node token.
NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"

curl -fsSL https://get.docker.com | sh

sudo usermod -aG docker $USER
sudo systemctl enable docker &> /dev/null
sudo systemctl start docker &> /dev/null

# Step 2: Install K3D
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Step 3: Install kubectl if not already installed
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Step 1: Create a Kubernetes Cluster (using the name 'cid-cluster')
k3d cluster create cid-cluster --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1
export KUBECONFIG=$(k3d kubeconfig merge cid-cluster --kubeconfig-switch-context)

echo $KUBECONFIG > /vagrant/.configs/kubeconfig

# Setup alias for kubectl to k
echo "[SETUP] : initiat aliases for all machine users "
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
