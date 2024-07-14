create
or replace function dance_api_public."uid" () returns text as $$
  select nullif(current_setting('jwt.claims.uid', true), '')::text;
$$ language sql stable;

grant
execute on dance_api_public."uid" to admin;
