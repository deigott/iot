#!/bin/bash


# Configure centos appstream mirrorlist
cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Installing Network tools (ifconfig)
sudo yum install net-tools -y

# Install K3s server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --flannel-iface=eth1" sh - && echo "[INFO]  Master is configured."

# Apply app1 deployment
sudo /usr/local/bin/kubectl apply -f /vagrant/confs/app1-deployment.yaml && echo "[INFO]  App1 is configured."
sudo kubectl wait deployment app-one --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO] App1 is deployed successfully"

# Apply app2 deployment
sudo /usr/local/bin/kubectl apply -f /vagrant/confs/app2-deployment.yaml && echo "[INFO]  App2 is configured."
sudo kubectl wait deployment app-two --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO] App2 is deployed successfully"

# Apply app3 deployment
sudo /usr/local/bin/kubectl apply -f /vagrant/confs/app3-deployment.yaml && echo "[INFO]  App3 is configured."
sudo kubectl wait deployment app-three --for condition=Available=True --timeout=-1s > /dev/null && echo "[INFO] App3 is deployed successfully"

# Apply Ingress
sudo /usr/local/bin/kubectl apply -f /vagrant/confs/ingress.yaml && echo "[INFO]  Ingress is configured."
kubectl wait ingress pro-ingress --for=condition=Admitted --timeout=-1s && kubectl get ingress <ingress-name> -o jsonpath='{.status.loadBalancer.ingress[0].ip}' && echo "Ingress IP assigned"


# Print Ingress IP
echo "[INFO]  Ingress IP: $INGRESS_IP"