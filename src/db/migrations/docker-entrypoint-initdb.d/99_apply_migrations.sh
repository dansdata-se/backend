#!/usr/bin/env bash
set -Eeuo pipefail

cd /etc/db

# Import helpers from docker-entrypoint.sh
# (this file has a specific check to prevent
# it from executing when being sourced)
# https://github.com/docker-library/postgres/blob/master/16/alpine3.20/docker-entrypoint.sh
source /usr/local/bin/docker-entrypoint.sh

file_env 'DB_OWNER_USER'
file_env 'DB_OWNER_PASSWORD'
file_env 'DB_NAME'

# HACK(FelixZY): Postgres only accepts connections over a unix domain socket
# during internal initialization. Unfortunately, graphile-migrate does not seem
# to support this. As a workaround, restart postgres with listen on localhost.
# https://github.com/docker-library/postgres/issues/474#issuecomment-410737234
pg_ctl -w -o "-c listen_addresses='localhost' -c shared_preload_libraries=timescaledb" -w restart

DATABASE_URL=${DATABASE_URL:-"postgres://${DB_OWNER_USER}:${DB_OWNER_PASSWORD}@localhost/${DB_NAME}"} bash -c 'graphile-migrate migrate'
