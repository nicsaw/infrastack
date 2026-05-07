#!/usr/bin/env bash

set -e

for svc in $(docker compose ps --services --filter status=running); do
  echo "=== $svc ==="
  docker compose pull "$svc"
done

docker compose up -d
docker image prune -f