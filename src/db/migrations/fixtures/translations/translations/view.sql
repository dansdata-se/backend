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
