--! Previous: sha1:397c185c23456bb5d2b27bd598662a4239c2ea79
--! Hash: sha1:866cf720f5d3d17db7e6eb7ff2d736705adc4f5c

-------------------------------------------------
-- keycloak
-------------------------------------------------
drop schema if exists "keycloak" cascade;

create schema if not exists "keycloak";

comment on schema "keycloak" is '
  Database used by keycloak for user management.
';

grant all privileges on schema "keycloak" to :DB_KEYCLOAK_USER;
