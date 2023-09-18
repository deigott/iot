#!/bin/bash

# Color codes for log levels
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

export EMAIL="mashad@student.1337.ma"
export DOMAIN="gitlab.mashad.ma"

# Function to confirm user input (y/n)
confirm() {
  while true; do
    read -p "Do you want to deploy Argo CD? (y/n): " choice
    case "$choice" in
      [Yy]*)
        return 0
        ;;
      [Nn]*)
        return 1
        ;;
      *)
        echo "Please enter 'y' for yes or 'n' for no."
        ;;
    esac
  done
}

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

# # Clean up GitLab
# log "INFO" "Deleting GitLab resources..."
# helm uninstall gitlab -n gitlab &> /dev/null
# log "INFO" "GitLab resources deleted successfully."

# # Step 1: Delete the Argo CD Namespace
# log "INFO" "Deleting Argo CD, gitlab and dev namespaces..."
# kubectl delete namespace argocd &> /dev/null
# kubectl delete namespace dev &> /dev/null
# kubectl delete namespace gitlab &> /dev/null
# log "INFO" "Argo CD, gitlab and dev namespaces deleted successfully."


# # Step 2: Delete the Kubernetes Cluster
# log "INFO" "Deleting the Kubernetes cluster..."
# k3d cluster delete cid-cluster &> /dev/null
# log "INFO" "Kubernetes cluster deleted successfully."

# # Step 3: Unset KUBECONFIG
# unset KUBECONFIG
# log "INFO" "KUBECONFIG unset."

# # Step 1: Create a Kubernetes Cluster (using the name 'cid-cluster')
# log "INFO" "Creating a Kubernetes cluster..."
# k3d cluster create cid-cluster --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1 &> /dev/null
# export KUBECONFIG=$(k3d kubeconfig merge cid-cluster --kubeconfig-switch-context)
# log "INFO" "Kubernetes cluster created successfully."

# # # Install GitLab
# # log "INFO" "Installing GitLab..."
# kubectl create namespace gitlab
# kubectl apply -f ../confs/gitlab-app.yml -n gitlab

# log "INFO" "GitLab installation initiated."
# log "INFO" "Waiting for GitLab to be deployed..."
# kubectl wait -n gitlab --for=condition=available deployment --all --timeout=-1s &> /dev/null
# log "INFO" "GitLab is deployed and ready."

# export GITLAB_IP=$(kubectl get svc -n gitlab|grep gitlab|awk '{print $4}'|tr ',' '\n'|head -n 1)
# export DEP_NAME=$(kubectl get pods -n gitlab|grep gitlab|awk '{print $1}')
# export GITLAB_PASSWORD=$(kubectl exec -it $DEP_NAME -n gitlab -- cat /etc/gitlab/initial_root_password|grep Password:|awk '{print $2}')
# sudo bash -c "echo '$GITLAB_IP $DOMAIN' >> /etc/hosts" &> /dev/null
# log "INFO" "GitLab UI is accessible at http://$DOMAIN:8080"

# # # Provide GitLab access information
# log "INFO" "GitLab is ready to use."
# log "INFO" "Gitlab password: $GITLAB_PASSWORD"
# log "INFO" "You can access the GitLab UI at http://$DOMAIN:8080"
# log "INFO" "Please follow the GitLab setup process."
# echo "********"

if confirm; then
    # Step 4: Install Argo CD
    log "INFO" "Installing Argo CD..."
    kubectl create namespace argocd &> /dev/null
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml &> /dev/null
    log "INFO" "Argo CD installation initiated."

    # Step 5: Wait for All Pods in the 'argocd' Namespace to Be Ready
    wait_for_pods "argocd"
    kubectl apply -f ../confs/appProject.yml

    # Step 6: Get Argo CD Password
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    log "INFO" "Argo CD admin password retrieved."

    # Creating the application
    log "INFO" "Creating 'dev' namespace and applying application configuration..."
    kubectl create namespace dev &> /dev/null
    kubectl apply -f ../confs/appAuth.yml &> /dev/null
    log "INFO" "Application configuration applied to 'dev' namespace."

    # Step 7: Wait for All Pods in the 'dev' Namespace to Be Ready
    wait_for_pods "dev"

    # Step 8: Port Forward to Access Argo CD UI
    log "INFO" "Port forwarding to access Argo CD UI..."
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &> /dev/null &
    log "INFO" "Argo CD UI is accessible at https://localhost:8080"

    # Step 9: Provide Access Information
    log "INFO" "Argo CD is ready to use."
    log "INFO" "You can access the Argo CD UI at https://localhost:8080"
    log "INFO" "Log in with the username 'admin' and the password: ${ARGOCD_PASSWORD}"
else
  log "INFO" "Argo CD deployment skipped as per user choice."
fi
# Prevent the script from exiting immediately
cat
