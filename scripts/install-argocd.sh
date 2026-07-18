#!/usr/bin/env bash

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script with sudo." >&2
  exit 1
fi

version="stable"

kubectl create namespace argocd \
  --dry-run=client \
  --output=yaml \
  | kubectl apply --filename=-

kubectl apply \
  --namespace=argocd \
  --server-side \
  --force-conflicts \
  --filename="https://raw.githubusercontent.com/argoproj/argo-cd/${version}/manifests/install.yaml"

kubectl wait \
  --namespace=argocd \
  --for=condition=Available \
  deployment \
  --all \
  --timeout=5m
