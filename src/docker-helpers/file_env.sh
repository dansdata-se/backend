# Extracted from https://github.com/docker-library/postgres/blob/66da3846b40396249936938ee17e9684e6968a57/16/bookworm/docker-entrypoint.sh
# Original license: MIT, Copyright (c) 2014, Docker PostgreSQL Authors (See AUTHORS)

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    printf >&2 'error: both %s and %s are set (but are exclusive)\n' "$var" "$fileVar"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}
