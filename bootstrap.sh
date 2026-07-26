#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -r /etc/os-release ]]; then
  echo "Unsupported host: /etc/os-release is unavailable." >&2
  exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
  echo "Unsupported host: Ubuntu 24.04 is required." >&2
  exit 1
fi

if [[ "$(cat /proc/1/comm)" != "systemd" ]]; then
  echo "Unsupported host: systemd must run as PID 1." >&2
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install --yes ansible-core
fi

cd "${repo_root}"
exec ansible-playbook --ask-become-pass ansible/playbooks/homelab.yml "$@"
