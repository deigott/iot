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


# Clean up GitLab
log "INFO" "Deleting GitLab resources..."
kubectl delete -f ../confs/gitlab-app.yml &> /dev/null
log "INFO" "GitLab resources deleted successfully."

# Step 1: Delete the Argo CD Namespace
log "INFO" "Deleting Argo CD, gitlab and dev namespaces..."
kubectl delete namespace argocd &> /dev/null
kubectl delete namespace dev &> /dev/null
kubectl delete namespace gitlab &> /dev/null
log "INFO" "Argo CD, gitlab and dev namespaces deleted successfully."


# Step 2: Delete the Kubernetes Cluster
log "INFO" "Deleting the Kubernetes cluster..."
k3d cluster delete cid-cluster &> /dev/null
log "INFO" "Kubernetes cluster deleted successfully."

# Step 3: Unset KUBECONFIG
unset KUBECONFIG
log "INFO" "KUBECONFIG unset."