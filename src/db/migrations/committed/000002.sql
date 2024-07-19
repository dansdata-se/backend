--! Previous: sha1:46fbc19243c5d57c8ecaed96112ce73cacd800fb
--! Hash: sha1:397c185c23456bb5d2b27bd598662a4239c2ea79

-------------------------------------------------
-- schema
-------------------------------------------------
drop schema if exists "translations" cascade;

create schema if not exists "translations";

comment on schema "translations" is '
  Data layer for string translations.
';

grant usage on schema "translations" to translations_reader;


-------------------------------------------------
-- metadata
-------------------------------------------------
create table translations.metadata(
  id int not null
    primary key
    generated always as identity,
  override_value text null
    default null
);

comment on table translations.metadata is '
  Contains metadata for translations.

  A translated string consists of one piece of metadata as well as zero or more
  `translations.values`.
';

comment on column translations.metadata.override_value is '
  A value to be used regardless of language.

  If this value is non-null, it should be used instead of any value from
  `translations.values`.
';


grant insert, update, delete on translations.metadata to translations_editor;


create or replace function
  translations.metadata_trigger_delete_values_when_overridden()
  returns trigger
  as $$
    begin
      if
        new.override_value is not null
      then
        delete from
          translations.values
        where
          metadata = new.id;
      end if;

      -- Ignored in "after" trigger
      return null;
    end;
  $$
  language plpgsql
  volatile
  security invoker;

comment on function
  translations.metadata_trigger_delete_values_when_overridden
is '
  Trigger that deletes any related values from `translations.values` if an
  override value is specified for the given translation''s metadata.
';

create trigger
  metadata_trigger_delete_values_when_overridden_after_insert_or_update
after insert or update on translations.metadata
  for each row execute function
    translations.metadata_trigger_delete_values_when_overridden();


-------------------------------------------------
-- languages
-------------------------------------------------
create table translations.languages(
  code text not null
    primary key,
  name int not null
    references translations.metadata(id) 
    on update cascade
    on delete cascade
);

comment on table translations.languages is '
  Contains all languages known to the system.
';

comment on column translations.languages.code is '
  An ISO 639-1 Alpha-2 language code.
';


grant select on translations.languages to translations_reader;


grant select, insert, update, delete on translations.languages to translations_admin;


-------------------------------------------------
-- values
-------------------------------------------------
create table translations.values(
  metadata int not null
    references translations.metadata(id)
    on update cascade
    on delete cascade,
  language text not null
    references translations.languages(code)
    on update cascade
    on delete cascade,
  value text not null,
  primary key(metadata, language)
);

comment on table translations.values is '
  Contains the translated texts for translations.
';


grant insert, update, delete on translations.values to translations_editor;


create or replace function
  translations.values_trigger_prevent_insert_when_overridden()
  returns trigger
  as $$
    declare
      is_overridden boolean = false;
    begin
      is_overridden = (
        select
          m.override_value is null
        from
          translations.metadata m
        where
          m.id = new.id
      );
      
      if is_overridden = true then return null;
      else return new;
      end if;
    end;
  $$
  language plpgsql
  volatile
  security invoker;

comment on function
  translations.values_trigger_prevent_insert_when_overridden
is '
  Trigger that prevents insertion to `translations.values` if an override
  value is specified for the given translation''s metadata.
';

create trigger
  values_trigger_prevent_insert_when_overridden_before_insert
before insert on translations.metadata
  for each row execute function
    translations.values_trigger_prevent_insert_when_overridden();


-------------------------------------------------
-- translations
-------------------------------------------------
create or replace view translations.translations
with (
  security_barrier = true
) as
  select
    m.id as metadata,
    l.code as code,
    coalesce(m.override_value, v.value, '') as value
  from
    translations.metadata m
    cross join translations.languages l
    left join translations.values v
      on
        v.metadata = m.id and
        v.language = l.code;

comment on view translations.translations is '
  A view of all translated strings, with values for all languages.

  Read operations should typically be performed on this view rather
  than the backing metadata/values tables.
';


grant select on translations.translations to translations_reader;


-------------------------------------------------
-- upsert_translations
-------------------------------------------------
create type translations.upsert_translations_input_type as (metadata int, language text, value text);
create domain translations.upsert_translations_input as translations.upsert_translations_input_type
check (
  (value).language is not null and
  (value).value is not null
);

create or replace function translations.upsert_translations (new_translations translations.upsert_translations_input[])
  returns void
  as $$
    declare
      t translations.upsert_translations_input_type;
    begin
      foreach t in array new_translations
      loop
        if t.language = '*'
        then
          if t.metadata is null
          then
            insert into
              translations.metadata(override_value)
            values
              (t.value);
          else
            update
              translations.metadata
            set
              override_value = t.value
            where
              id = t.metadata;
          end if;
        else
          if t.metadata is null
          then
            insert into
              translations.metadata
            default values
            returning id
              into t.metadata;
          else
            update
              translations.metadata
            set
              override_value = null
            where
              id = t.metadata;
          end if;

          insert into
            translations.values(metadata, language, value)
          select
            t.metadata,
            t.language,
            t.value
          on conflict(metadata, language)
            do update set
              value = t.value;
        end if;
      end loop;
    end;
  $$
  language plpgsql
  volatile
  security invoker;


comment on function translations.upsert_translations is '
  Creates or updates the given translation with new values.

  If the language is specified as "*", the translation will be used for all
  languages.
';


-------------------------------------------------
-- Create language entries for swedish, english
-- and norwegian.
-------------------------------------------------
with create_metadata as (
  insert into translations.metadata default values returning id
)
insert into translations.languages(code, name)
select 'sv', id from create_metadata;

with create_metadata as (
  insert into translations.metadata default values returning id
)
insert into translations.languages(code, name)
select 'en', id from create_metadata;

with create_metadata as (
  insert into translations.metadata default values returning id
)
insert into translations.languages(code, name)
select 'no', id from create_metadata;

select translations.upsert_translations(array[
  (
    (select name from translations.languages where code = 'sv'),
    'sv',
    'Svenska'
  ),
  (
    (select name from translations.languages where code = 'sv'),
    'en',
    'Swedish'
  ),
  (
    (select name from translations.languages where code = 'sv'),
    'no',
    'Svensk'
  ),
  (
    (select name from translations.languages where code = 'en'),
    'sv',
    'Engelska'
  ),
  (
    (select name from translations.languages where code = 'en'),
    'en',
    'English'
  ),
  (
    (select name from translations.languages where code = 'en'),
    'no',
    'Engelsk'
  ),
  (
    (select name from translations.languages where code = 'no'),
    'sv',
    'Norska'
  ),
  (
    (select name from translations.languages where code = 'no'),
    'en',
    'Norwegian'
  ),
  (
    (select name from translations.languages where code = 'no'),
    'no',
    'Norsk'
  )
]::translations.upsert_translations_input[]);
