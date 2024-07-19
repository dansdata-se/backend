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
