#!/usr/bin/env bash

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

# Unlock the dashboard (insecure)
kubectl create \
    --save-config \
    -f dashboard-admin.yaml

kubectl create serviceaccount spark

kubectl create clusterrolebinding spark-role \
    --clusterrole=edit \
    --serviceaccount=default:spark \
    --namespace=default