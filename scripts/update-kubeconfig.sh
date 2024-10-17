#!/bin/bash
response="$(aws eks list-clusters --region us-west-2 --output text | grep -i eks-xplur-cluster 2>&1)" 
if [[ $? -eq 0 ]]; then
    echo "Success: xplur-cluster exist"
    aws eks --region us-west-2 update-kubeconfig --name eks-xplur-cluster && export KUBE_CONFIG_PATH=~/.kube/config

else
    echo "Error: xplur-cluster does not exist"
fi