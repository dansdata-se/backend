#!/usr/bin/env bash
set -Eeuo pipefail

cd /docker-entrypoint-initdb.d/

# Import helpers from docker-entrypoint.sh
# (this file has a specific check to prevent
# it from executing when being sourced)
# https://github.com/docker-library/postgres/blob/master/16/alpine3.20/docker-entrypoint.sh
source /usr/local/bin/docker-entrypoint.sh

file_env 'DB_OWNER_USER'
file_env 'DB_APP_AUTH_USER'
file_env 'DB_KEYCLOAK_USER'
file_env 'DB_NAME'
file_env 'ENVIRONMENT'

create_db() {
  local db_name=$1
  # Create database
  docker_process_sql \
    -v DB_OWNER="$DB_OWNER_USER" \
    -v DB_NAME="$db_name" \
    -f templates/create_database.sql

  # Grant basic connect access for users
  docker_process_sql \
    -v USERNAME="$DB_APP_AUTH_USER" \
    -v DB_NAME="$db_name" \
    <<< 'grant connect on database :DB_NAME to :USERNAME;'

  docker_process_sql \
    -v USERNAME="$DB_KEYCLOAK_USER" \
    -v DB_NAME="$db_name" \
    <<< 'grant connect on database :DB_NAME to :USERNAME;'

  # Add extensions
  docker_process_sql \
    --dbname="$db_name" \
    -f templates/create_extensions.sql
}

create_db "$DB_NAME"

if [ "$ENVIRONMENT" == "development" ]; then
  create_db "${DB_NAME}_shadow"
else
  echo "Shadow database not created: \"$ENVIRONMENT\" != \"development\""
fi
