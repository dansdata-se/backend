-------------------------------------------------
-- System roles
-------------------------------------------------
-- This file defines the roles used as basic
-- building blocks for RBAC.
--
-- Roles are organized approximately from low
-- access to high.
-------------------------------------------------
--
--
-------------------------------------------------
-------------------------------------------------
-- anonymous
-------------------------------------------------
-- anonymous is our keyword for a role with
-- PUBLIC access only.
--
-- This role should never be GRANTed permissions
-- directly; instead, GRANTS involving anonymous
-- should target PUBLIC.
-------------------------------------------------
create role anonymous;

-------------------------------------------------
-------------------------------------------------
-- actor
-------------------------------------------------
-- Intended for database operations on actors
-------------------------------------------------
create role actor_reader;

create role actor_editor;

create role actor_admin;

grant actor_reader to actor_editor;

grant actor_editor to actor_admin;

-------------------------------------------------
-------------------------------------------------
-- event
-------------------------------------------------
-- Intended for database operations on events
-------------------------------------------------
create role event_reader;

create role event_editor;

create role event_admin;

grant event_reader to event_editor;

grant event_editor to event_admin;

-------------------------------------------------
-------------------------------------------------
-- reader
-------------------------------------------------
-- A blanket role for reading data in the system.
-------------------------------------------------
create role reader;

grant actor_reader to reader;

grant event_reader to reader;

-------------------------------------------------
-------------------------------------------------
-- editor
-------------------------------------------------
-- A blanket role for modifying informational
-- data in the system.
-------------------------------------------------
create role editor;

grant actor_editor to editor;

grant event_editor to editor;

grant reader to editor;

-------------------------------------------------
-------------------------------------------------
-- admin
-------------------------------------------------
-- Intended for approved administrators to
-- perform tasks that go beyond what normal
-- editors should be able to do.
-------------------------------------------------
create role admin;

grant actor_admin to admin;

grant event_admin to admin;

grant editor to admin;
