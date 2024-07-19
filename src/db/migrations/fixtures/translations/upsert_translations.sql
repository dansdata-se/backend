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
