#!/usr/bin/env bash
set -Eeo pipefail

source file_env.sh

file_env 'GATEWAY_HOST'
file_env 'APP_HOST'

exec "$@"
