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
