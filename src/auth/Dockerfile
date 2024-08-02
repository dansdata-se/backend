FROM quay.io/keycloak/keycloak:25.0 AS builder

ENV KC_DB postgres
ENV KC_DB_SCHEMA keycloak
ENV KC_HEALTH_ENABLED true
ENV KC_METRICS_ENABLED true
ENV KC_HTTP_ENABLED true
ENV KC_PROXY_HEADERS xforwarded
ENV KC_HTTP_MAX_QUEUED_REQUESTS 25

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:25.0

ENV KC_DB postgres
ENV KC_DB_SCHEMA keycloak
ENV KC_HEALTH_ENABLED true
ENV KC_METRICS_ENABLED true
ENV KC_HTTP_ENABLED true
ENV KC_PROXY_HEADERS xforwarded
ENV KC_HTTP_MAX_QUEUED_REQUESTS 25

COPY --from=builder /opt/keycloak/ /opt/keycloak/

COPY --chmod=555 --from=docker-helpers file_env.sh /usr/local/bin/
COPY --chmod=555 docker-entrypoint.sh /usr/local/bin/
COPY --chmod=444 ./realms/* /opt/keycloak/data/import/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/opt/keycloak/bin/kc.sh", "start", "--optimized", "--import-realm"]
