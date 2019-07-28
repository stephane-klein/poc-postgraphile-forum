\echo "Database cleaning..."
SET client_min_messages TO WARNING;

DROP SCHEMA IF EXISTS forum_example CASCADE;
DROP SCHEMA IF EXISTS forum_example_private CASCADE;

DROP ROLE IF EXISTS forum_example_postgraphile;
DROP ROLE IF EXISTS forum_example_anonymous;
DROP ROLE IF EXISTS forum_example_person;

CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA forum_example;
CREATE SCHEMA forum_example_private;

\echo "Database cleaned"
