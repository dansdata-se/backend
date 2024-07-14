-------------------------------------------------
-- events
-------------------------------------------------
drop schema if exists "events" cascade;

create schema if not exists "events";

--!include schemas/events.sql

-------------------------------------------------
-- actors
-------------------------------------------------
drop schema if exists "actors" cascade;

create schema if not exists "actors";

--!include schemas/actors.sql

-------------------------------------------------
-- dance_api_public
-------------------------------------------------
drop schema if exists "dance_api_public" cascade;

create schema if not exists "dance_api_public";

--!include schemas/dance_api_public.sql
