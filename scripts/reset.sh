#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

cat sql/schema/*.sql | docker-compose exec -T postgres psql --quiet -U admin poc-forum
cat sql/demo-data.sql | docker-compose exec -T postgres psql --quiet -U admin poc-forum
