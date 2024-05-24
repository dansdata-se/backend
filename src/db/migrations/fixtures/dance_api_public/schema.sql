comment on schema "dance_api_public" is '
  Repository layer for accessing the data available in dansdata''s data sources.

  This is the schema used by Postgraphile to expose our GraphQL API.
';

grant usage on schema "dance_api_public" to public;
