#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker-compose exec postgres psql -U admin poc-forum