#!/usr/bin/env bash
set -Eeuo pipefail

source file_env.sh

file_env 'DOCKER_DATABASE_HOST'
file_env 'DB_NAME'
file_env 'KC_DB_USERNAME'
file_env 'KC_DB_PASSWORD'
file_env 'KC_DB_SCHEMA'
file_env 'KC_HOSTNAME'
file_env 'KC_HOSTNAME_ADMIN'
file_env 'KEYCLOAK_ADMIN'
file_env 'KEYCLOAK_ADMIN_PASSWORD'

export KC_DB_URL="jdbc:postgresql://${DOCKER_DATABASE_HOST}/${DB_NAME}"

exec "$@"
