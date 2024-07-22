FROM caddy:2.8-alpine

RUN apk add --no-cache bash

COPY Caddyfile /etc/caddy/Caddyfile

COPY --from=docker-helpers file_env.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
