drop database if exists :"DB_NAME";

create database :"DB_NAME"
with
  owner :"DB_OWNER" --
  encoding 'UTF8' --
  locale_provider icu --
  icu_locale "sv-SE" --
  template template0;

revoke all on database :"DB_NAME"
from
  public;
