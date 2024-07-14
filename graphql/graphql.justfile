set dotenv-load := true
set dotenv-path := "../secrets/.env"

[private]
default: help

# Show this help text
help:
    @just --list gql --justfile {{ justfile() }}

# Start the API
start:
    @npx postgraphile
