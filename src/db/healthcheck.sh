#!/usr/bin/env bash
set -Eeuo pipefail

# Import helpers from docker-entrypoint.sh
# (this file has a specific check to prevent
# it from executing when being sourced)
# https://github.com/docker-library/postgres/blob/master/16/alpine3.20/docker-entrypoint.sh
source /usr/local/bin/docker-entrypoint.sh

file_env 'DB_OWNER_USER'
file_env 'DB_OWNER_PASSWORD'
file_env 'DB_HOST'
file_env 'DB_NAME'

psql "postgres://${DB_OWNER_USER}:${DB_OWNER_PASSWORD}@${DB_HOST}/${DB_NAME}" -AXqtc "select setting from pg_settings where name = 'listen_addresses';" | grep '*'
