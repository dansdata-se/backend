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
