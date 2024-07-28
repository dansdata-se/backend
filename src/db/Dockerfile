FROM postgres:16-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    lsb-release \
  && echo "deb https://packagecloud.io/timescale/timescaledb/debian $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/timescaledb.list \
  && wget -qO - https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/timescaledb.gpg \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    postgresql-16-postgis-3 \
    timescaledb-2-postgresql-16 \
  && rm -rf /var/lib/apt/lists/*

COPY ./migrations/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

CMD ["postgres", "-c", "shared_preload_libraries=timescaledb"]
