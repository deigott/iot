#!/bin/bash

export EMAIL="mashad@student.1337.ma"
export DOMAIN="gitlab.mashad.ma"

export KUBECONFIG="/vagrant/.configs/kubeconfig"

chmod 700 $KUBECONFIG

curl -fsSL https://get.docker.com | sh &> /dev/null

sudo usermod -aG docker $USER
sudo systemctl enable docker &> /dev/null
sudo systemctl start docker &> /dev/null

curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash &> /dev/null

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &> /dev/null
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Setup alias for kubectl to k
echo "[SETUP] : initiat aliases for all machine users "
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

kubectl create namespace gitlab

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh && ./get_helm.sh

helm repo add gitlab https://charts.gitlab.io/

helm search repo gitlab

helm install gitlab gitlab/gitlab \
    --set global.hosts.domain=$DOMAIN \
    --set certmanager-issuer.email=$EMAIL \
    --set global.hosts.https="false" \
    --set global.ingress.configureCertmanager="false" \
    --set gitlab-runner.install="false" \
    --set global.edition=ce \
    -n gitlab

echo -n "[INFO]   Gitlab password: "

kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 -d; echo

echo 'Waiting for gitlab to be deployed'
kubectl wait -n gitlab --for=condition=available deployment --all --timeout=-1s

echo "[INFO]  Forwarding port."

kubectl port-forward --address 192.168.56.111 svc/gitlab-webservice-default -n gitlab 8080:8181