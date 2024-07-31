#!/usr/bin/env bash
set -Eeo pipefail

source file_env.sh

file_env 'DOMAIN_API_DANSDATA'
file_env 'DOMAIN_ADMIN_DANSDATA'
file_env 'DOCKER_DANCE_API_HOST'
file_env 'DOCKER_KEYCLOAK_HOST'

exec "$@"
