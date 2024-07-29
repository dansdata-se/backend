comment on schema "keycloak" is '
  Database used by keycloak for user management.
';

grant all privileges on schema "keycloak" to :DB_KEYCLOAK_USER;
