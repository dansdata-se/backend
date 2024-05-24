#################################################
# Basic just configuration
#################################################

environment := env_var_or_default("ENVIRONMENT", "development")

[private]
default: help

# Show this help text
[group("General")]
help: current_environment
    @just --list app --unsorted --justfile {{ justfile() }}

#################################################
# Internal utils
#################################################

# Print the environment of the variables in the current .env file
[private]
current_environment:
    @export \
        ENVIRONMENT={{ quote(environment) }} \
        && bun zx -- ../../.tooling/env/log_current_env.ts
