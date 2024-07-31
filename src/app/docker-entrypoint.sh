#!/usr/bin/env bash
set -Eeo pipefail

source file_env.sh

file_env 'DOCKER_DANCE_API_HOST'

exec "$@"
