#!/bin/bash
# Check if the EKS cluster exists in the specified region
if aws eks list-clusters --region us-west-2 --output text | grep -q "eks-xplur-cluster"; then
    echo "Success: eks-xplur-cluster exists"

    # Attempt to update the kubeconfig
    if aws eks --region us-west-2 update-kubeconfig --name eks-xplur-cluster; then
        export KUBE_CONFIG_PATH=~/.kube/config
        echo "Kubeconfig updated and KUBE_CONFIG_PATH set."
    else
        echo "Error: Failed to update kubeconfig."
        exit 1
    fi
else
    echo "Error: eks-xplur-cluster does not exist"
    echo "Try again"
    exit 1
fi
