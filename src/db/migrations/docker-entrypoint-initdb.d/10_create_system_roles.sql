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
-- translations
-------------------------------------------------
-- Intended for database operations on
-- translations
-------------------------------------------------
create role translations_reader;

create role translations_editor;

create role translations_admin;

grant translations_reader to translations_editor;

grant translations_editor to translations_admin;

-------------------------------------------------
-------------------------------------------------
-- reader
-------------------------------------------------
-- A blanket role for reading data in the system.
-------------------------------------------------
create role reader;

grant translations_reader to reader;

-------------------------------------------------
-------------------------------------------------
-- editor
-------------------------------------------------
-- A blanket role for modifying informational
-- data in the system.
-------------------------------------------------
create role editor;

grant reader to editor;

grant translations_editor to editor;

-------------------------------------------------
-------------------------------------------------
-- admin
-------------------------------------------------
-- Intended for approved administrators to
-- perform tasks that go beyond what normal
-- editors should be able to do.
-------------------------------------------------
create role admin;

grant editor to admin;

grant translations_admin to admin;
