#!/usr/bin/env bash
set -Eeuo pipefail

cd /docker-entrypoint-initdb.d/

# Import helpers from docker-entrypoint.sh
# (this file has a specific check to prevent
# it from executing when being sourced)
# https://github.com/docker-library/postgres/blob/master/16/alpine3.20/docker-entrypoint.sh
source /usr/local/bin/docker-entrypoint.sh

file_env 'DB_KEYCLOAK_USER'
file_env 'DB_KEYCLOAK_PASSWORD'

docker_process_sql \
  -v USERNAME="$DB_KEYCLOAK_USER" \
  -v PASSWORD="$DB_KEYCLOAK_PASSWORD" \
  -f templates/create_user.sql
