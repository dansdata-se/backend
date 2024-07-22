FROM oven/bun:1 AS build
WORKDIR /tmp/app

# Install dependencies separately to cache them
COPY package.json bun.lockb ./dev/
COPY package.json bun.lockb ./prod/
RUN cd dev && bun install --ignore-scripts --frozen-lockfile
RUN cd prod && bun install --ignore-scripts --frozen-lockfile --production

# Import source code
COPY . dev/
COPY . prod/

# Run tests & build
RUN cd dev && bun test
ENV NODE_ENV=production
RUN cd prod && bun run build

FROM bitnami/minideb:bookworm AS release

RUN install_packages curl

# Copy built binary into production image
COPY --from=build /tmp/app/prod/dist/app/dance_api /

# Create a non-root user and switch to it
RUN groupadd -r dansdata && useradd -r -g dansdata dansdata
USER dansdata

ARG APP_HOST=localhost:3000

EXPOSE 3000/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD curl --fail http://localhost:3000/healthz || exit 1

COPY --from=docker-helpers file_env.sh /usr/local/bin/
COPY --from=build /tmp/app/prod/src/app/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/dance_api"]
