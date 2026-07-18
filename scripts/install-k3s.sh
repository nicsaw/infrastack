#!/usr/bin/env bash

set -euo pipefail

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script with sudo." >&2
  exit 1
fi

curl --fail --silent --show-error --location https://get.k3s.io | sh -

systemctl is-active --quiet k3s
kubectl get nodes
