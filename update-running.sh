#!/usr/bin/env bash

for svc in $(docker compose ps --services --filter status=running); do
  echo "=== $svc ==="
  docker compose pull "$svc"
done
