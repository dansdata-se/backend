drop schema if exists "dansdata" cascade;

create schema if not exists "dansdata";

grant usage on schema "dansdata" to anonymous;

drop schema if exists "portal" cascade;

create schema if not exists "portal";

grant usage on schema "portal" to editor;

drop schema if exists "metrics" cascade;

create schema if not exists "metrics";

grant usage on schema "metrics" to api_reader;

drop schema if exists "translations" cascade;

create schema if not exists "translations";

grant usage on schema "translations" to anonymous;

create extension if not exists pg_trgm
with
  schema dansdata;

--!include functions/uid.sql
drop type if exists translations.language_code cascade;

create type translations.language_code as enum('sv', 'en');

comment on type translations.language_code is '
  @name LanguageCode

  Supported ISO 639-1 two-letter language codes.
';

create or replace view translations.languages (code) as (
  select
    unnest(enum_range(null::translations.language_code))
);

comment on view translations.languages is '
  @behavior -*
';

drop table if exists translations.translation_metadatas cascade;

create table translations.translation_metadatas (id serial primary key);

comment on table translations.translation_metadatas is '
  @behavior -*
';

drop table if exists translations.translations cascade;

create table translations.translations (
  metadata_id integer references translations.translation_metadatas (id) on delete cascade,
  language translations.language_code not null,
  value text not null,
  primary key (metadata_id, language)
);

comment on table translations.translations is '
  @behavior -*
';

create or replace view translations.full_translations as (
  select
    tm.id as metadata_id,
    l.code as language,
    coalesce(t.value, '') as value
  from
    translations.translation_metadatas tm
    cross join translations.languages l
    left join translations.translations t on tm.id = t.metadata_id
    and t.language = l.code
);

comment on view translations.full_translations is '
  @behavior -*

  Lists every single translation metadata and language combination mapped to
  the corresponding translated string (or an empty string if there is no
  corresponding translation).
';

grant
select
  on translations.full_translations to anonymous;

drop type if exists translations.translation cascade;

create type translations.translation as (language translations.language_code, value text);

comment on type translations.translation is '
  @name Translation
';

comment on column translations.translation.language is '
  @behavior +filterBy
  @notNull
';

comment on column translations.translation.value is '
  @notNull
';

create
or replace function translations.get_translations (
  id integer,
  languages translations.language_code[]
) returns setof translations.translation as $$
  SELECT
    language,
    value
  FROM
    translations.full_translations
  WHERE
    id IS NOT NULL
    AND languages IS NOT NULL
    AND metadata_id = id
    AND language = ANY (languages)
$$ language sql stable security invoker;

comment on function translations.get_translations is '
  @behavior -*

  Helper function to reduce code duplication when retrieving translations. 
';

/* PROFILE */
drop type if exists dansdata.profile_type cascade;

create type dansdata.profile_type as enum('organization', 'individual', 'venue');

drop table if exists dansdata.profiles cascade;

create table dansdata.profiles (
  id uuid default gen_random_uuid () primary key,
  type profile_type not null,
  title text not null,
  description_id integer default null references translations.translation_metadatas (id)
);

create index profiles_type_idx on dansdata.profiles (type);

create index profiles_title_idx on dansdata.profiles using gist (title gist_trgm_ops);

comment on table dansdata.profiles is '
  @name Profile
  @interface mode:relational type:type
  @type individual references:individuals
  @type organization references:organizations
  @type venue references:venues
  @ref organizations to:OrganizationMember plural
  @refVia organizations via:(id)->organization_members(member_id)

  Represents an entity with profile data.
';

comment on column dansdata.profiles.description_id is '
  @behavior -*
';

create
or replace function dansdata.profiles_description (
  profile dansdata.profiles,
  languages translations.language_code[]
) returns setof translations.translation as $$
  SELECT translations.get_translations(profile.description_id, languages);
$$ language sql stable security invoker;

comment on function dansdata.profiles_description is '
  @behavior -connection +list -list:filter -list:order
';

grant
select
  on dansdata.profiles to anonymous;

grant insert,
update,
delete on dansdata.profiles to editor;

/* INDIVIDUAL */
drop table if exists dansdata.individuals cascade;

create table dansdata.individuals (
  id uuid primary key references dansdata.profiles (id) on delete cascade
);

comment on table dansdata.individuals is '
  @name Individual
  @ref organizations to:OrganizationMember plural
  @refVia organizations via:profiles;(id)->organization_members(member_id)

  Represents an individual person.
';

grant
select
  on dansdata.individuals to anonymous;

grant insert,
update,
delete on dansdata.individuals to editor;

create
or replace function dansdata.create_individual (title text) returns dansdata.individuals as $$
  with
    "profile" as (
      insert into
        dansdata.profiles ("type", "title")
      values
        ('individual', title)
      returning
        *
    )
  insert into
    dansdata.individuals ("id") (
      select
        id
      from
        "profile"
    )
  returning
    *;
$$ language sql volatile strict security invoker;

/* ORGANIZATION */
drop table if exists dansdata.organizations cascade;

create table dansdata.organizations (
  id uuid primary key references dansdata.profiles (id) on delete cascade
);

comment on table dansdata.organizations is '
  @name Organization
  @ref organizations to:OrganizationMember plural
  @refVia organizations via:profiles;(id)->organization_members(member_id)

  Represents an organization entity.
';

grant
select
  on dansdata.organizations to anonymous;

grant insert,
update,
delete on dansdata.organizations to editor;

create
or replace function dansdata.create_organization (title text) returns dansdata.organizations as $$
  WITH "profile" AS (
    INSERT INTO dansdata.profiles("type", "title") VALUES ('organization', title) RETURNING *
  ) INSERT INTO dansdata.organizations("id") (SELECT id from "profile") RETURNING *;
$$ language sql volatile strict security invoker;

/* VENUE */
drop table if exists dansdata.venues cascade;

create table dansdata.venues (
  id uuid primary key references dansdata.profiles (id) on delete cascade
);

comment on table dansdata.venues is '
  @name Venue
  @ref organizations to:OrganizationMember plural
  @refVia organizations via:profiles;(id)->organization_members(member_id)

  Represents a venue.
';

grant
select
  on dansdata.venues to anonymous;

grant insert,
update,
delete on dansdata.venues to editor;

create
or replace function dansdata.create_venue (title text) returns dansdata.venues as $$
  WITH "profile" AS (
    INSERT INTO dansdata.profiles("type", "title") VALUES ('venue', title) RETURNING *
  ) INSERT INTO dansdata.venues("id") (SELECT id from "profile") RETURNING *;
$$ language sql volatile strict security invoker;

/* ******** */
/* PROFILE_LINKS */
drop table if exists dansdata.profile_links cascade;

create table dansdata.profile_links (
  id serial primary key,
  profile_id uuid references dansdata.profiles (id) on delete cascade,
  url text not null,
  unique (profile_id, url)
);

grant
select
  on dansdata.profile_links to anonymous;

grant insert,
update,
delete on dansdata.profile_links to editor;

comment on table dansdata.profile_links is '
  @name ProfileLink
  @behavior -query -connection -list +manyRelation:resource:list
';

comment on constraint profile_links_profile_id_fkey on dansdata.profile_links is '
  @foreignFieldName links
';

/* PROFILE_TAGS */
drop table if exists dansdata.profile_tags cascade;

create table dansdata.profile_tags (
  id serial not null primary key,
  tag text not null unique,
  description_id integer default null references translations.translation_metadatas (id) on delete set null,
  individuals boolean not null default false,
  organizations boolean not null default false,
  venues boolean not null default false
);

comment on column dansdata.profile_tags.description_id is '
  @name ProfileTag
';

create
or replace function dansdata.profile_tags_description (
  tag dansdata.profile_tags,
  languages translations.language_code[]
) returns setof translations.translation as $$
  SELECT translations.get_translations(tag.description_id, languages);
$$ language sql stable security invoker;

comment on function dansdata.profile_tags_description is '
  @behavior -connection +list -list:filter -list:order
';

drop table if exists dansdata.profile_tags_junction cascade;

create table dansdata.profile_tags_junction (
  profile_id uuid references dansdata.profiles (id) on delete cascade,
  tag_id integer not null references dansdata.profile_tags (id) on delete cascade,
  primary key (profile_id, tag_id)
);

comment on table dansdata.profile_tags_junction is '
  @behavior -*
';

create
or replace function dansdata.profiles_tags (profile dansdata.profiles) returns setof dansdata.profile_tags as $$
  SELECT
    t.*
  FROM
    dansdata.profile_tags_junction j
    INNER JOIN dansdata.profile_tags t ON j.tag_id = t.id
  WHERE
    j.profile_id = profile.id;
$$ language sql stable security invoker;

comment on function dansdata.profiles_tags is '
  @behavior -connection +list -list:filter -list:order
';

grant
select
  on dansdata.profile_tags_junction to anonymous;

grant insert,
update,
delete on dansdata.profile_tags_junction to editor;

/* TODO(FelixZY): Add pre-insert/update trigger to prevent tag(individual=false) to be assigned to an individual etc.! */
grant
select
  (id, tag, description_id) on dansdata.profile_tags to anonymous;

grant
select
,
  insert,
update,
delete on dansdata.profile_tags to admin;

drop view if exists dansdata.individual_tags cascade;

create view dansdata.individual_tags as (
  select
    id,
    tag,
    description_id
  from
    dansdata.profile_tags
  where
    individuals = true
);

comment on view dansdata.individual_tags is '
  @primaryKey id
  @returnType ProfileTag
';

grant
select
  on individual_tags to anonymous;

drop view if exists dansdata.organization_tags cascade;

create view dansdata.organization_tags as (
  select
    id,
    tag,
    description_id
  from
    dansdata.profile_tags
  where
    organizations = true
);

comment on view dansdata.organization_tags is '
  @primaryKey id
  @returnType ProfileTag
';

grant
select
  on organization_tags to anonymous;

drop view if exists dansdata.venue_tags cascade;

create view dansdata.venue_tags as (
  select
    id,
    tag,
    description_id
  from
    dansdata.profile_tags
  where
    venues = true
);

comment on view dansdata.venue_tags is '
  @primaryKey id
  @returnType ProfileTag
';

grant
select
  on venue_tags to anonymous;

/* ORGANIZATION_MEMBER */
drop table if exists dansdata.organization_members cascade;

create table dansdata.organization_members (
  organization_id uuid references dansdata.organizations (id) on delete cascade,
  member_id uuid references dansdata.profiles (id) on delete cascade,
  check (organization_id <> member_id),
  title text,
  primary key (organization_id, member_id)
);

comment on table dansdata.organization_members is '
  @name OrganizationMember

  Represents a profile that is a member of an organization
';

comment on constraint organization_members_organization_id_fkey on dansdata.organization_members is '
  @foreignFieldName members
';

grant
select
  on dansdata.organization_members to anonymous;

grant insert,
update,
delete on dansdata.organization_members to editor;

create
or replace function dansdata.add_organization_member (
  organization_id uuid,
  member_id uuid,
  title text = null
) returns dansdata.organization_members as $$
  INSERT INTO
    dansdata.organization_members ("organization_id", "member_id", "title")
  VALUES
    (organization_id, member_id, title)
  RETURNING
    *;
$$ language sql volatile security invoker;

comment on function dansdata.add_organization_member is '
  @behavior -*
';

create
or replace function dansdata.postgraphile_add_organization_member (
  organization_id dansdata.organizations,
  member_id dansdata.profiles,
  title text = null
) returns dansdata.organization_members as $$
  SELECT dansdata.add_organization_member (organization_id.id, member_id.id, title);
$$ language sql volatile security invoker;

comment on function dansdata.postgraphile_add_organization_member is '
  @name addOrganizationMember
  @arg0variant nodeId
  @arg1variant nodeId
';

create
or replace function dansdata.autocomplete_profile (title_query text, type profile_type = null) returns setof dansdata.profiles as $$
  #variable_conflict use_variable
  BEGIN
    RETURN QUERY
    SELECT
      *
    FROM
      dansdata.profiles p
    WHERE
      p.title %> title_query
      AND (
        type IS NULL
        OR p.type = type
      )
    ORDER BY
      word_similarity (title_query, title) DESC
    LIMIT
      10;
  END
$$ language plpgsql stable security invoker;

comment on function dansdata.autocomplete_profile is '
  @behavior -connection +list -list:filter -list:order

  Provides up to ten profile suggestions based on a given search query,
  optionally filtered by profile type. The result is intended to be used
  when autocompleting text inputs.

  **Please try to avoid repeat lookups.** Use a local cache for recent
  searches to reduce our server load and improve your user-percieved
  performance.
';

drop table if exists dansdata.mytab;

create table dansdata.mytab (
  id serial primary key,
  name_trans integer not null references translations.translation_metadatas (id)
);

comment on column dansdata.mytab.name_trans is '
  @translation name
';

grant
select
  on dansdata.mytab to anonymous;

insert into
  translations.translation_metadatas
values
  (default),
  (default);

insert into
  translations.translations
values
  (1, 'sv', 'Hej');

insert into
  translations.translations
values
  (1, 'en', 'Hello');

insert into
  translations.translations
values
  (2, 'sv', 'Världen');

insert into
  translations.translations
values
  (2, 'en', 'World');

insert into
  dansdata.mytab (name_trans)
values
  (1);

insert into
  dansdata.mytab (name_trans)
values
  (2);

-- /* PROFILE */
-- DROP TYPE if EXISTS dansdata.profile_type cascade;
-- CREATE TYPE dansdata.profile_type AS ENUM('organization', 'individual', 'venue');
-- DROP TABLE IF EXISTS dansdata.profiles cascade;
-- CREATE TABLE dansdata.profiles (
--   id UUID DEFAULT gen_random_uuid () PRIMARY KEY,
--   type profile_type NOT NULL,
--   title TEXT NOT NULL,
--   description_id INTEGER DEFAULT NULL REFERENCES translations.translation_metadatas (id)
-- );
-- CREATE INDEX profiles_type_idx ON dansdata.profiles (type);
-- CREATE INDEX profiles_title_idx ON dansdata.profiles USING gist (title gist_trgm_ops);
-- comment ON TABLE dansdata.profiles IS '
--   @name Profile
--   @interface mode:relational type:type
--   @type individual references:individuals
--   @type organization references:organizations
--   @type venue references:venues
--   @ref organizations to:OrganizationMember plural
--   @refVia organizations via:(id)->organization_members(member_id)
--   Represents an entity with profile data.
-- ';
-- comment ON COLUMN dansdata.profiles.description_id IS '
--   @behavior -*
-- ';
-- -- CREATE
-- -- OR REPLACE function dansdata.profiles_description (
-- --   profile dansdata.profiles,
-- --   languages translations.language_code[]
-- -- ) returns setof translations.translation AS $$
-- --   SELECT translations.get_translations(profile.description_id, languages);
-- -- $$ language sql stable security invoker;
-- -- comment ON function dansdata.profiles_description IS '
-- --   @behavior -connection +list -list:filter -list:order
-- -- ';
-- GRANT
-- SELECT
--   ON dansdata.profiles TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.profiles TO editor;
-- /* INDIVIDUAL */
-- DROP TABLE IF EXISTS dansdata.individuals cascade;
-- CREATE TABLE dansdata.individuals (
--   id UUID PRIMARY KEY REFERENCES dansdata.profiles (id) ON DELETE cascade
-- );
-- comment ON TABLE dansdata.individuals IS '
--   @name Individual
--   @ref organizations to:OrganizationMember plural
--   @refVia organizations via:profiles;(id)->organization_members(member_id)
--   Represents an individual person.
-- ';
-- GRANT
-- SELECT
--   ON dansdata.individuals TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.individuals TO editor;
-- CREATE
-- OR REPLACE function dansdata.create_individual (title TEXT) returns dansdata.individuals AS $$
--   WITH "profile" AS (
--     INSERT INTO dansdata.profiles("type", "title") VALUES ('individual', title) RETURNING *
--   ) INSERT INTO dansdata.individuals("id") (SELECT id from "profile") RETURNING *;
-- $$ language sql volatile strict security invoker;
-- /* ORGANIZATION */
-- DROP TABLE IF EXISTS dansdata.organizations cascade;
-- CREATE TABLE dansdata.organizations (
--   id UUID PRIMARY KEY REFERENCES dansdata.profiles (id) ON DELETE cascade
-- );
-- comment ON TABLE dansdata.organizations IS '
--   @name Organization
--   @ref organizations to:OrganizationMember plural
--   @refVia organizations via:profiles;(id)->organization_members(member_id)
--   Represents an organization entity.
-- ';
-- GRANT
-- SELECT
--   ON dansdata.organizations TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.organizations TO editor;
-- CREATE
-- OR REPLACE function dansdata.create_organization (title TEXT) returns dansdata.organizations AS $$
--   WITH "profile" AS (
--     INSERT INTO dansdata.profiles("type", "title") VALUES ('organization', title) RETURNING *
--   ) INSERT INTO dansdata.organizations("id") (SELECT id from "profile") RETURNING *;
-- $$ language sql volatile strict security invoker;
-- /* VENUE */
-- DROP TABLE IF EXISTS dansdata.venues cascade;
-- CREATE TABLE dansdata.venues (
--   id UUID PRIMARY KEY REFERENCES dansdata.profiles (id) ON DELETE cascade
-- );
-- comment ON TABLE dansdata.venues IS '
--   @name Venue
--   @ref organizations to:OrganizationMember plural
--   @refVia organizations via:profiles;(id)->organization_members(member_id)
--   Represents a venue.
-- ';
-- GRANT
-- SELECT
--   ON dansdata.venues TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.venues TO editor;
-- CREATE
-- OR REPLACE function dansdata.create_venue (title TEXT) returns dansdata.venues AS $$
--   WITH "profile" AS (
--     INSERT INTO dansdata.profiles("type", "title") VALUES ('venue', title) RETURNING *
--   ) INSERT INTO dansdata.venues("id") (SELECT id from "profile") RETURNING *;
-- $$ language sql volatile strict security invoker;
-- /* ******** */
-- /* PROFILE_LINKS */
-- DROP TABLE IF EXISTS dansdata.profile_links cascade;
-- CREATE TABLE dansdata.profile_links (
--   id serial PRIMARY KEY,
--   profile_id UUID REFERENCES dansdata.profiles (id) ON DELETE cascade,
--   url TEXT NOT NULL,
--   UNIQUE (profile_id, url)
-- );
-- GRANT
-- SELECT
--   ON dansdata.profile_links TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.profile_links TO editor;
-- comment ON TABLE dansdata.profile_links IS '
--   @name ProfileLink
--   @behavior -query -connection -list +manyRelation:resource:list
-- ';
-- comment ON CONSTRAINT profile_links_profile_id_fkey ON dansdata.profile_links IS '
--   @foreignFieldName links
-- ';
-- /* PROFILE_TAGS */
-- DROP TABLE IF EXISTS dansdata.profile_tags cascade;
-- CREATE TABLE dansdata.profile_tags (
--   id serial NOT NULL PRIMARY KEY,
--   tag TEXT NOT NULL UNIQUE,
--   description_id INTEGER DEFAULT NULL REFERENCES translations.translation_metadatas (id) ON DELETE SET NULL,
--   individuals BOOLEAN NOT NULL DEFAULT FALSE,
--   organizations BOOLEAN NOT NULL DEFAULT FALSE,
--   venues BOOLEAN NOT NULL DEFAULT FALSE
-- );
-- comment ON COLUMN dansdata.profile_tags.description_id IS '
--   @behavior -*
-- ';
-- -- CREATE
-- -- OR REPLACE function dansdata.profile_tags_description (
-- --   tag dansdata.profile_tags,
-- --   languages translations.language_code[]
-- -- ) returns setof translations.translation AS $$
-- --   SELECT translations.get_translations(tag.description_id, languages);
-- -- $$ language sql stable security invoker;
-- -- comment ON function dansdata.profile_tags_description IS '
-- --   @behavior -connection +list -list:filter -list:order
-- -- ';
-- DROP TABLE IF EXISTS dansdata.profile_tags_junction cascade;
-- CREATE TABLE dansdata.profile_tags_junction (
--   profile_id UUID REFERENCES dansdata.profiles (id) ON DELETE cascade,
--   tag_id INTEGER NOT NULL REFERENCES dansdata.profile_tags (id) ON DELETE cascade,
--   PRIMARY KEY (profile_id, tag_id)
-- );
-- comment ON TABLE dansdata.profile_tags_junction IS '
--   @behavior -*
-- ';
-- CREATE
-- OR REPLACE function dansdata.profiles_tags (profile dansdata.profiles) returns setof dansdata.profile_tags AS $$
--   SELECT
--     t.*
--   FROM
--     dansdata.profile_tags_junction j
--     INNER JOIN dansdata.profile_tags t ON j.tag_id = t.id
--   WHERE
--     j.profile_id = profile.id;
-- $$ language sql stable security invoker;
-- comment ON function dansdata.profiles_tags IS '
--   @behavior -connection +list -list:filter -list:order
-- ';
-- GRANT
-- SELECT
--   ON dansdata.profile_tags_junction TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.profile_tags_junction TO editor;
-- /* TODO(FelixZY): Add pre-insert/update trigger to prevent tag(individual=false) to be assigned to an individual etc.! */
-- GRANT
-- SELECT
--   (id, tag, description_id) ON dansdata.profile_tags TO anonymous;
-- GRANT
-- SELECT
-- ,
--   insert,
-- UPDATE,
-- delete ON dansdata.profile_tags TO admin;
-- DROP VIEW if EXISTS dansdata.individual_tags cascade;
-- CREATE VIEW dansdata.individual_tags AS (
--   SELECT
--     id,
--     tag,
--     description_id
--   FROM
--     dansdata.profile_tags
--   WHERE
--     individuals = TRUE
-- );
-- comment ON view dansdata.individual_tags IS '
--   @primaryKey id
--   @returnType ProfileTag
-- ';
-- GRANT
-- SELECT
--   ON individual_tags TO anonymous;
-- DROP VIEW if EXISTS dansdata.organization_tags cascade;
-- CREATE VIEW dansdata.organization_tags AS (
--   SELECT
--     id,
--     tag,
--     description_id
--   FROM
--     dansdata.profile_tags
--   WHERE
--     organizations = TRUE
-- );
-- comment ON view dansdata.organization_tags IS '
--   @primaryKey id
--   @returnType ProfileTag
-- ';
-- GRANT
-- SELECT
--   ON organization_tags TO anonymous;
-- DROP VIEW if EXISTS dansdata.venue_tags cascade;
-- CREATE VIEW dansdata.venue_tags AS (
--   SELECT
--     id,
--     tag,
--     description_id
--   FROM
--     dansdata.profile_tags
--   WHERE
--     venues = TRUE
-- );
-- comment ON view dansdata.venue_tags IS '
--   @primaryKey id
--   @returnType ProfileTag
-- ';
-- GRANT
-- SELECT
--   ON venue_tags TO anonymous;
-- /* ORGANIZATION_MEMBER */
-- DROP TABLE IF EXISTS dansdata.organization_members cascade;
-- CREATE TABLE dansdata.organization_members (
--   organization_id UUID REFERENCES dansdata.organizations (id) ON DELETE cascade,
--   member_id UUID REFERENCES dansdata.profiles (id) ON DELETE cascade,
--   CHECK (organization_id <> member_id),
--   title TEXT,
--   PRIMARY KEY (organization_id, member_id)
-- );
-- comment ON TABLE dansdata.organization_members IS '
--   @name OrganizationMember
--   Represents a profile that is a member of an organization
-- ';
-- comment ON CONSTRAINT organization_members_organization_id_fkey ON dansdata.organization_members IS '
--   @foreignFieldName members
-- ';
-- GRANT
-- SELECT
--   ON dansdata.organization_members TO anonymous;
-- GRANT insert,
-- UPDATE,
-- delete ON dansdata.organization_members TO editor;
-- CREATE
-- OR REPLACE function dansdata.add_organization_member (
--   organization_id UUID,
--   member_id UUID,
--   title TEXT = NULL
-- ) returns dansdata.organization_members AS $$
--   INSERT INTO
--     dansdata.organization_members ("organization_id", "member_id", "title")
--   VALUES
--     (organization_id, member_id, title)
--   RETURNING
--     *;
-- $$ language sql volatile security invoker;
-- comment ON function dansdata.add_organization_member IS '
--   @behavior -*
-- ';
-- CREATE
-- OR REPLACE function dansdata.postgraphile_add_organization_member (
--   organization_id dansdata.organizations,
--   member_id dansdata.profiles,
--   title TEXT = NULL
-- ) returns dansdata.organization_members AS $$
--   SELECT dansdata.add_organization_member (organization_id.id, member_id.id, title);
-- $$ language sql volatile security invoker;
-- comment ON function dansdata.postgraphile_add_organization_member IS '
--   @name addOrganizationMember
--   @arg0variant nodeId
--   @arg1variant nodeId
-- ';
-- CREATE
-- OR REPLACE function dansdata.autocomplete_profile (title_query TEXT, type profile_type = NULL) returns setof dansdata.profiles AS $$
--   #variable_conflict use_variable
--   BEGIN
--     RETURN QUERY
--     SELECT
--       *
--     FROM
--       dansdata.profiles p
--     WHERE
--       p.title %> title_query
--       AND (
--         type IS NULL
--         OR p.type = type
--       )
--     ORDER BY
--       word_similarity (title_query, title) DESC
--     LIMIT
--       10;
--   END
-- $$ language plpgsql stable security invoker;
-- comment ON function dansdata.autocomplete_profile IS '
--   @behavior -connection +list -list:filter -list:order
--   Provides up to ten profile suggestions based on a given search query,
--   optionally filtered by profile type. The result is intended to be used
--   when autocompleting text inputs.
--   **Please try to avoid repeat lookups.** Use a local cache for recent
--   searches to reduce our server load and improve your user-percieved
--   performance.
-- ';
