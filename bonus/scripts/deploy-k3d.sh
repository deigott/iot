#!/bin/bash

# Color codes for log levels
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

# Function to print log messages with color and log level
log() {
  local level="$1"
  local message="$2"
  local color=""
  case "$level" in
    "INFO")
      color="${GREEN}"
      ;;
    "WARNING")
      color="${YELLOW}"
      ;;
    "ERROR")
      color="${RED}"
      ;;
    *)
      color="${NC}"
      ;;
  esac
  echo -e "[${color}${level}${NC}] ${message}"
}

# Function to wait for all pods in a namespace to be ready
wait_for_pods() {
  local namespace="$1"
  log "INFO" "Waiting for all pods in namespace '${namespace}' to be ready..."
  while [[ $(kubectl get pods -n ${namespace} -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | sort | uniq) != "True" ]]; do
    sleep 5
  done
  log "INFO" "All pods in namespace '${namespace}' are ready."
}

# Step 2: Delete the Argo CD Namespace
log "INFO" "Deleting Argo CD and dev namespaces..."
kubectl delete namespace argocd &> /dev/null
kubectl delete namespace dev &> /dev/null
log "INFO" "Argo CD and dev namespaces deleted successfully."

# Step 1: Delete the Kubernetes Cluster
log "INFO" "Deleting the Kubernetes cluster..."
k3d cluster delete cid-cluster &> /dev/null
log "INFO" "Kubernetes cluster deleted successfully."

# Step 3: Unset KUBECONFIG
unset KUBECONFIG
log "INFO" "KUBECONFIG unset."

# Step 1: Create a Kubernetes Cluster (using the name 'cid-cluster')
log "INFO" "Creating a Kubernetes cluster..."
k3d cluster create cid-cluster --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1 &> /dev/null
export KUBECONFIG=$(k3d kubeconfig merge cid-cluster --kubeconfig-switch-context)
log "INFO" "Kubernetes cluster created successfully."

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

echo "[INFO]  Forwarding port."

kubectl port-forward --address 192.168.56.111 svc/gitlab-webservice-default -n gitlab 1337:8181 &> /dev/null


# # Step 4: Install Argo CD
# log "INFO" "Installing Argo CD..."
# kubectl create namespace argocd &> /dev/null
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml &> /dev/null
# log "INFO" "Argo CD installation initiated."

# # Step 5: Wait for All Pods in the 'argocd' Namespace to Be Ready
# wait_for_pods "argocd"

# # Step 6: Get Argo CD Password
# ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
# log "INFO" "Argo CD admin password retrieved."

# # Creating the application
# log "INFO" "Creating 'dev' namespace and applying application configuration..."
# kubectl create namespace dev &> /dev/null
# kubectl apply -f ../confs/appAuth.yml &> /dev/null
# log "INFO" "Application configuration applied to 'dev' namespace."

# # Step 7: Wait for All Pods in the 'dev' Namespace to Be Ready
# wait_for_pods "dev"

# # Step 8: Port Forward to Access Argo CD UI
# log "INFO" "Port forwarding to access Argo CD UI..."
# kubectl port-forward svc/argocd-server -n argocd 8080:443 &> /dev/null &
# log "INFO" "Argo CD UI is accessible at https://localhost:8080"

# # Step 9: Provide Access Information
# log "INFO" "Argo CD is ready to use."
# log "INFO" "You can access the Argo CD UI at https://localhost:8080"
# log "INFO" "Log in with the username 'admin' and the password: ${ARGOCD_PASSWORD}"

# # Prevent the script from exiting immediately
# cat
