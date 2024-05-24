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
-- reader
-------------------------------------------------
-- A blanket role for reading data in the system.
-------------------------------------------------
create role reader;

-------------------------------------------------
-------------------------------------------------
-- editor
-------------------------------------------------
-- A blanket role for modifying informational
-- data in the system.
-------------------------------------------------
create role editor;

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

grant editor to admin;
