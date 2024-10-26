#!/bin/bash
# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install curl if not installed
if ! command_exists curl; then
    echo "Installing curl..."
    sudo apt-get install -y curl
fi

# Install Helm if not installed
if ! command_exists helm; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm is already installed."
fi

# Verify Helm installation
echo "Verifying Helm installation..."
helm version

# Create a namespace for Helm (optional)
if ! kubectl get namespace helm-charts >/dev/null 2>&1; then
    echo "Creating namespace helm-charts..."
    kubectl create namespace helm-charts
else
    echo "Namespace helm-charts already exists."
fi

# Add the stable Helm repo
echo "Adding the stable Helm repository..."
helm repo add stable https://charts.helm.sh/stable

# Update Helm repositories
echo "Updating Helm repositories..."
helm repo update

echo "Helm installation completed!"
