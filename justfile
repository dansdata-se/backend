#################################################
# Basic just configuration
#################################################

environment := env_var_or_default("ENVIRONMENT", "development")
secrets_path := "secrets/" + environment
dotenv_path := "secrets/.env"

set dotenv-load := true
set dotenv-path := "./secrets/.env"

mod app "src/app/.app.justfile"
mod auth "src/auth/.auth.justfile"
mod db "src/db/.db.justfile"

[private]
default: help

# Show this help text
[group("General")]
help: current_environment
    @just --list --unsorted --justfile {{ justfile() }}

#################################################
# Code Utils
#################################################

# Reformat all source files
[group("Code Utils")]
format:
    @bun prettier -w .
    @just --fmt
    @just --fmt --justfile src/app/.app.justfile
    @just --fmt --justfile src/auth/.auth.justfile
    @just --fmt --justfile src/db/.db.justfile

# Lint source files
[group("Code Utils")]
lint:
    @bun tsc
    @bun eslint .

#################################################
# Environment
#################################################

# CHange ENVironment
[group("Environment")]
chenv new_env:
    @export \
        ENVIRONMENT={{ quote(new_env) }} \
        && just genenv

# Generate a .env file based on secrets/{environment}. Set the `ENVIRONMENT` envvar to change environment.
[group("Environment")]
genenv:
    @export \
        DOTENV_PATH={{ quote(dotenv_path) }} \
        SECRETS_PATH={{ quote(secrets_path) }} \
        && bun zx -- .tooling/env/generate_dotenv_file.ts

# Print the environment of the variables in the current .env file
[group("Environment")]
current_environment:
    @export \
        ENVIRONMENT={{ quote(environment) }} \
        && bun zx -- .tooling/env/log_current_env.ts

#################################################
# Internal utils
#################################################

# Configures bash completions for graphile-migrate and just. This will modify your '~/.bashrc'!
[private]
enable_bash_completions:
    @bun graphile-migrate completion >> ~/.bashrc
    @just --completions bash > ~/.just.sh
    @echo 'source ~/.just.sh' >> ~/.bashrc
    @echo "Please run 'source ~/.just.sh' in any active shells!"
