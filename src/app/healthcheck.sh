#!/usr/bin/env bash
set -Eeuo pipefail

source /usr/local/bin/file_env.sh

file_env 'APP_HOST'

curl --fail http://${APP_HOST}/healthz || exit 1
