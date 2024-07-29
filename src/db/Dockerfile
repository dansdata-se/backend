# HACK(FelixZY): use bun to compile a standalone executable of
# graphile-migrate, allowing us to use the tool from within the database
# container.
FROM oven/bun:1 AS build-graphile-migrate
WORKDIR /tmp/app

COPY package.json bun.lockb ./
RUN bun install --ignore-scripts --frozen-lockfile

ENV NODE_ENV=production
RUN bun build --compile --target=bun-linux-x64-modern --minify --sourcemap node_modules/graphile-migrate/dist/cli.js --outfile dist/db/graphile-migrate

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

# Copy graphile-migrate binary into production image
COPY --from=build-graphile-migrate /tmp/app/dist/db/graphile-migrate /usr/local/bin/

COPY ./src/db/migrations/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

COPY --chmod=444 ./src/db/.gmrc /etc/db/
COPY --chmod=444 ./src/db/migrations/committed/*.sql /etc/db/migrations/committed/

COPY --chmod=555 ./src/db/healthcheck.sh /usr/local/bin/
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --start-interval=2s --retries=3 CMD healthcheck.sh

CMD ["postgres", "-c", "shared_preload_libraries=timescaledb"]
