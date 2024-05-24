create schema if not exists extensions;

grant usage on schema extensions to public;

create extension if not exists plpgsql
with
  schema extensions;

create extension if not exists "uuid-ossp"
with
  schema extensions;

create extension if not exists pgcrypto
with
  schema extensions;

create extension if not exists postgis
with
  schema extensions;
