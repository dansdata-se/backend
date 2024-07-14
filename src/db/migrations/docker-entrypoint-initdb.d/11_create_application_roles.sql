-------------------------------------------------
-- Application roles
-------------------------------------------------
-- This file defines the roles typically used
-- by the different types of applications that
-- connect to the system.
-------------------------------------------------
--
--
-------------------------------------------------
-------------------------------------------------
-- app_dance_api
-------------------------------------------------
-- Intended for applications accessing the public
-- dansdata api.
-------------------------------------------------
-- The dansdata api may provide certain access to
-- unauthorized applications for demonstration
-- purposes.
create role app_dance_api_anonymous;

grant anonymous to app_dance_api_anonymous;

-------------------------------------------------
-- However, most information access requires an
-- authorized application.
create role app_dance_api_authorized;

grant actor_reader to app_dance_api_authorized;

grant event_reader to app_dance_api_authorized;
