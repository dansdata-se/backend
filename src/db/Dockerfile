FROM postgis/postgis:16-3.4-alpine

RUN apk add --no-cache musl-locales

COPY ./migrations/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

# Do not automatically set up postgis in the default database
# See https://github.com/postgis/docker-postgis/blob/6c43b39522f2de801ee83f09f631af1f0fbc2aad/16-3.4/alpine/Dockerfile#L123C26-L123C67
RUN rm /docker-entrypoint-initdb.d/10_postgis.sh
