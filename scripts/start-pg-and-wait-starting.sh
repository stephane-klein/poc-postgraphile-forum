#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker-compose up -d postgres

NETWORK_NAME=$(docker inspect $(docker-compose ps -q postgres) -f "{{ range \$key, \$value := .NetworkSettings.Networks }}{{ \$key }}{{end}}" | head -n1)

docker run --network ${NETWORK_NAME} --rm harobed/wait -c postgres:5432