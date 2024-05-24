--! Previous: -
--! Hash: sha1:46fbc19243c5d57c8ecaed96112ce73cacd800fb

-------------------------------------------------
-- dance_api_public
-------------------------------------------------
drop schema if exists "dance_api_public" cascade;

create schema if not exists "dance_api_public";

comment on schema "dance_api_public" is '
  Repository layer for accessing the data available in dansdata''s data sources.

  This is the schema used by Postgraphile to expose our GraphQL API.
';

grant usage on schema "dance_api_public" to public;
