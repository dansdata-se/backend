FROM quay.io/keycloak/keycloak:25.0 AS builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

ENV KC_DB=postgres

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:25.0

ENV KC_DB=postgres

COPY --from=builder /opt/keycloak/ /opt/keycloak/

COPY --chmod=555 --from=docker-helpers file_env.sh /usr/local/bin/
COPY --chmod=555 docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
