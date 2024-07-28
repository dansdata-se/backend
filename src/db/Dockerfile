FROM postgres:16

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    postgresql-16-postgis-3 \
  ; \
  rm -rf /var/lib/apt/lists/*

COPY ./migrations/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
