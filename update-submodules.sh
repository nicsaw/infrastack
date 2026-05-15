#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

git submodule sync --recursive

git submodule update --init --recursive

docker compose up -d --build seek-scraper
