#################################################
# Basic just configuration
#################################################

environment := env_var_or_default("ENVIRONMENT", "development")

# Configure environment variables required by graphile-migrate

export DATABASE_URL := "postgres://" + encode_uri_component(env_var_or_default("DB_OWNER_USER", "user")) + ":" + encode_uri_component(env_var_or_default("DB_OWNER_PASSWORD", "password")) + "@" + env_var_or_default("DB_HOST", "localhost") + "/" + encode_uri_component(env_var_or_default("DB_NAME", ""))

# SHADOW and ROOT are required in development only

export SHADOW_DATABASE_URL := DATABASE_URL + "_shadow"
export ROOT_DATABASE_URL := "postgres://" + encode_uri_component(env_var_or_default("DBMS_OWNER_USER", "postgres")) + ":" + encode_uri_component(env_var_or_default("DBMS_OWNER_PASSWORD", "postgres")) + "@" + env_var_or_default("DB_HOST", "localhost") + "/" + encode_uri_component(env_var_or_default("DBMS_OWNER_USER", "postgres"))

[private]
default: help

# Show this help text
[group("General")]
help: current_environment
    @just --list db --unsorted --justfile {{ justfile() }}

#################################################
# General
#################################################

# Indicates the current migration status
[group("General")]
status:
    @bun zx -- ../../.tooling/db/migration_status.ts

#################################################
# Development
#################################################

# Seed the database with mock data
[group("Development")]
seed:
    @npx graphile-migrate run migrations/seed.sql

#################################################
# Migrations
#################################################

# Applies all committed migrations as well as `current.sql`
[group("Development")]
[group("Migrations")]
apply: migrate
    @bun graphile-migrate watch --once

# Applies all committed migrations
[group("Migrations")]
migrate:
    @bun graphile-migrate migrate

# Commits the current migration into the `committed/` folder
[group("Migrations")]
commit:
    @bun graphile-migrate commit

# Moves the latest commit out of the committed migrations folder and back `current.sql`
[group("Migrations")]
uncommit:
    @bun graphile-migrate uncommit

#################################################
# Connect
#################################################

# Connect to api application's user via usql
[group("Connect")]
connect_app: (usql_connect env_var("DB_APP_AUTH_USER") env_var("DB_APP_AUTH_PASSWORD"))

# Connect to keycloak's database user via usql
[group("Connect")]
connect_keycloak: (usql_connect env_var("DB_KEYCLOAK_USER") env_var("DB_KEYCLOAK_PASSWORD"))

# Connect to the owner of the database via usql
[group("Connect")]
connect_db_owner db_name=env_var("DB_NAME"): (usql_connect env_var("DB_OWNER_USER") env_var("DB_OWNER_PASSWORD") db_name)

# Connect to the owner of the entire DBMS via usql
[group("Connect")]
connect_dbms_owner db_name=env_var("DB_NAME"): (usql_connect env_var("DBMS_OWNER_USER") env_var("DBMS_OWNER_PASSWORD") db_name)

[group("Connect")]
[private]
usql_connect user password db_name=env_var("DB_NAME"):
    @usql "postgres://{{ encode_uri_component(user) }}:{{ encode_uri_component(password) }}@{{ env_var("DB_HOST") }}/{{ db_name }}"

#################################################
# Internal utils
#################################################

# Print the environment of the variables in the current .env file
[private]
current_environment:
    @export \
        ENVIRONMENT={{ quote(environment) }} \
        && bun zx -- ../../.tooling/env/log_current_env.ts
