set dotenv-load := true
set dotenv-path := "../secrets/.env"

# Configure environment variables required by graphile-migrate

export DATABASE_URL := "postgres://" + encode_uri_component(env_var("DB_OWNER_USER")) + ":" + encode_uri_component(env_var("DB_OWNER_PASSWORD")) + "@" + env_var("DB_HOST") + ":" + env_var("DB_PORT") + "/" + env_var("DB_NAME")

# SHADOW and ROOT are required in development only

export SHADOW_DATABASE_URL := DATABASE_URL + "_shadow"
export ROOT_DATABASE_URL := "postgres://" + encode_uri_component(env_var("DBMS_OWNER_USER")) + ":" + encode_uri_component(env_var("DBMS_OWNER_PASSWORD")) + "@" + env_var("DB_HOST") + ":" + env_var("DB_PORT") + "/" + env_var("DBMS_OWNER_USER")

[private]
default: help

# Show this help text
help:
    @just --list db --justfile {{ justfile() }}

# Connect to the user used by postgraphile via usql
connect: (usql_connect env_var("DB_APP_AUTH_USER") env_var("DB_APP_AUTH_PASSWORD"))

# Connect to the owner of the database via usql
connect_db_owner db_name=env_var("DB_NAME"): (usql_connect env_var("DB_OWNER_USER") env_var("DB_OWNER_PASSWORD") db_name)

# Connect to the owner of the entire DBMS via usql
connect_dbms_owner db_name=env_var("DB_NAME"): (usql_connect env_var("DBMS_OWNER_USER") env_var("DBMS_OWNER_PASSWORD") db_name)

[private]
usql_connect user password db_name=env_var("DB_NAME"):
    @usql "postgres://{{ encode_uri_component(user) }}:{{ encode_uri_component(password) }}@{{ env_var("DB_HOST") }}:{{ env_var("DB_PORT") }}/{{ db_name }}"

# Commits the current migration into the `committed/` folder
commit:
    @npx graphile-migrate commit

# Moves the latest commit out of the committed migrations folder and back to the current migration
uncommit:
    @npx graphile-migrate uncommit

# Commits the current migration into the `committed/` folder
migrate:
    @npx graphile-migrate migrate

apply_current: migrate
    @npx graphile-migrate run migrations/current.sql

seed:
    @npx graphile-migrate run migrations/seed.sql

# Indicates the current migration status
status:
    #!/usr/bin/env -S npx zx
    const statusCode = await $`npx graphile-migrate status`.exitCode;
    switch(statusCode) {
        case 0:
            console.log(chalk.green("✅ Up-to-date"));
            break;
        case 1:
        case 3:
            console.log(chalk.yellow("⚠️ One or more migrations have not yet been deployed"));
            if (statusCode == 1) {
                break;
            }
        case 2:
            console.log(chalk.yellow("⚠️ The current migration has not yet been committed"));
            break;
        default:
            console.error(`❌ Unknown status: ${statusCode}`)
    }

# **HIGHLY DESTRUCTIVE** Drops and re-creates the database
reset:
    @npx graphile-migrate reset --erase
