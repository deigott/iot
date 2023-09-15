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

# Step 1: Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    log "INFO" "Installing Docker..."
    curl -fsSL https://get.docker.com | sh &> /dev/null
    sudo usermod -aG docker $USER
    sudo systemctl enable docker &> /dev/null
    sudo systemctl start docker &> /dev/null
    log "INFO" "Docker installed successfully."
else
    log "INFO" "Docker is already installed."
fi

# Step 2: Install K3D
if ! command -v k3d &> /dev/null; then
    log "INFO" "Installing K3D..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash &> /dev/null
    echo "source <(k3d completion bash)" >> ~/.zshrc
    log "INFO" "K3D installed successfully."
else
    log "INFO" "K3D is already installed."
fi

# Step 3: Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    log "INFO" "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &> /dev/null
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    log "INFO" "kubectl installed successfully."
else
    log "INFO" "kubectl is already installed."
fi
