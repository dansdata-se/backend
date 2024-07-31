#!/usr/bin/env bash
set -Eeuo pipefail

source /usr/local/bin/file_env.sh

file_env 'DOCKER_DANCE_API_HOST'

curl --fail http://${DOCKER_DANCE_API_HOST}/healthz || exit 1
